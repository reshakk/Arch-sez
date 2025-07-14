import sys
from datetime import datetime
import html
from collections import defaultdict

def generate_html_report(error_file):
    # Read errors and group by file
    errors_by_file = defaultdict(list)
    with open(error_file, 'r') as f:
        for line in f:
            # Split line into filename and error message
            if ':' in line:
                filename, error = line.split(':', 1)
                errors_by_file[filename].append(error.strip())
            else:
                # Handle case where no filename is present (unlikely with -H)
                errors_by_file['Unknown'].append(line.strip())

    # Start HTML content
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Error Report</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 20px; }}
            h1 {{ color: #333; }}
            h2 {{ color: #555; margin-top: 20px; }}
            table {{ border-collapse: collapse; width: 100%; margin-bottom: 20px; }}
            th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
            th {{ background-color: #f2f2f2; }}
            tr:nth-child(even) {{ background-color: #f9f9f9; }}
        </style>
    </head>
    <body>
        <h1>Error Report</h1>
        <p>Generated on: {}</p>
    """.format(timestamp)

    # Add a section for each log file
    for filename, errors in sorted(errors_by_file.items()):
        # Escape filename for HTML
        escaped_filename = html.escape(filename)
        html_content += f"""
        <h2>Log File: {escaped_filename}</h2>
        <table>
            <tr>
                <th>Error Message</th>
            </tr>
        """
        # Add errors for this file
        for error in errors:
            escaped_error = html.escape(error)
            html_content += f"            <tr><td>{escaped_error}</td></tr>\n"
        html_content += "        </table>\n"

    # Close HTML content
    html_content += """
    </body>
    </html>
    """

    # Write to HTML file
    with open('error_report.html', 'w') as f:
        f.write(html_content)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 generate_report.py <error_file>")
        sys.exit(1)
    
    error_file = sys.argv[1]
    generate_html_report(error_file)
    print("HTML report generated: error_report.html")
