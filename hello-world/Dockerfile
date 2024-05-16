# Use the official Golang image as the build environment
FROM golang:1.22 AS build

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /bin/bootstrap main.go

# Now copy it into our base image.
FROM public.ecr.aws/lambda/provided:al2

# Copy the binary to the /var/task directory
COPY --from=build /bin/bootstrap /var/task/

# Command to run the binary
CMD ["bootstrap"]
