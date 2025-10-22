# Use official Python image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy Python dependencies
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source code
COPY . .

# Expose the port Flask runs on
EXPOSE 5000

# Set environment variable
ENV FLASK_ENV=production
ENV FLASK_APP=app.py

# Run the app
CMD ["python", "app.py"]
