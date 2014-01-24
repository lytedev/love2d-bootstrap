# Go to root of project
cd $2

# Remove and recreate bin directory
echo "Removing existing bin directory..."
rm -r bin
echo "Creating bin directory..."
mkdir bin

# Zip up the project
echo "Building .love file..."
7z a bin/$1.love

# Run
echo "Running..."
echo "\n"
love bin/$1.love
