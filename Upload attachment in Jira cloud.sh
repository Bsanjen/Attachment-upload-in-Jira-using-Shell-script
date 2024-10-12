JIRA_BASE_URL="https://ABC.atlassian.net/rest/api/3/issue"
JIRA_USERNAME="ABC@gmail.com"  # Your Jira email
JIRA_API_TOKEN="___"         # Your Jira API token
CSV_FILE="/attachment/path/Attachment.csv"  # Path to your CSV file

# Read CSV file and upload attachments
while IFS=, read -r issue_key attachment_path; do
    # Skip empty lines or lines with no issue key or attachment path
    if [[ -z "$issue_key" || -z "$attachment_path" ]]; then
        continue
    fi

    # Check if the attachment file exists
    if [[ -f "$attachment_path" ]]; then
        echo "Uploading $attachment_path to $issue_key..."

        # Use curl to upload the attachment and capture the HTTP status code
        response=$(curl -s --write-out "HTTPSTATUS:%{http_code}" --request POST \
            --url "$JIRA_BASE_URL/$issue_key/attachments" \
            --user "$JIRA_USERNAME:$JIRA_API_TOKEN" \
            --header "X-Atlassian-Token: no-check" \
            --form "file=@$attachment_path")

        # Extract body and status code
        response_body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
        http_status=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

        # Check for success
        if [[ "$http_status" -eq 200 || "$http_status" -eq 201 ]]; then
            echo "Successfully uploaded $attachment_path to $issue_key."
            echo "Response: $response_body"  # Print the full response body
        else
            echo "Failed to upload $attachment_path to $issue_key. HTTP Status: $http_status. Response: $response_body"
        fi
    else
        echo "Attachment file $attachment_path does not exist."
    fi
done < <(tail -n +2 "$CSV_FILE")
