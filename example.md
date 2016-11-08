# dtagfs example
File 'orange.jpg' with tags 'fruit', 'colour:orange', and 'citrus fruit'.  
File 'lemon.jpg' with tags 'fruit', 'colour:yellow', and 'citrus fruit'.  
File 'strawberry.jpg' with tags 'fruit', and 'colour:red'.  
File 'lemonade.jpg' with tags 'beverage', and 'colour:yellow'.  

Mounting this yields the following file system tree:
	mountpoint/
	├── beverage
	│   ├── colour:yellow
	│   │   └── lemonade.jpg
	│   └── lemonade.jpg
	├── citrus fruit
	│   ├── colour:orange
	│   │   ├── fruit
	│   │   │   └── orange.jpg
	│   │   └── orange.jpg
	│   ├── colour:yellow
	│   │   ├── fruit
	│   │   │   └── lemon.jpg
	│   │   └── lemon.jpg
	│   ├── fruit
	│   │   ├── colour:orange
	│   │   │   └── orange.jpg
	│   │   ├── colour:yellow
	│   │   │   └── lemon.jpg
	│   │   ├── lemon.jpg
	│   │   └── orange.jpg
	│   ├── lemon.jpg
	│   └── orange.jpg
	├── colour:orange
	│   ├── citrus fruit
	│   │   ├── fruit
	│   │   │   └── orange.jpg
	│   │   └── orange.jpg
	│   ├── fruit
	│   │   ├── citrus fruit
	│   │   │   └── orange.jpg
	│   │   └── orange.jpg
	│   └── orange.jpg
	├── colour:red
	│   ├── fruit
	│   │   └── strawberry.jpg
	│   └── strawberry.jpg
	├── colour:yellow
	│   ├── beverage
	│   │   └── lemonade.jpg
	│   ├── citrus fruit
	│   │   ├── fruit
	│   │   │   └── lemon.jpg
	│   │   └── lemon.jpg
	│   ├── fruit
	│   │   ├── citrus fruit
	│   │   │   └── lemon.jpg
	│   │   └── lemon.jpg
	│   ├── lemonade.jpg
	│   └── lemon.jpg
	├── fruit
	│   ├── citrus fruit
	│   │   ├── colour:orange
	│   │   │   └── orange.jpg
	│   │   ├── colour:yellow
	│   │   │   └── lemon.jpg
	│   │   ├── lemon.jpg
	│   │   └── orange.jpg
	│   ├── colour:orange
	│   │   ├── citrus fruit
	│   │   │   └── orange.jpg
	│   │   └── orange.jpg
	│   ├── colour:red
	│   │   └── strawberry.jpg
	│   ├── colour:yellow
	│   │   ├── citrus fruit
	│   │   │   └── lemon.jpg
	│   │   └── lemon.jpg
	│   ├── lemon.jpg
	│   ├── orange.jpg
	│   └── strawberry.jpg
	├── lemonade.jpg
	├── lemon.jpg
	├── orange.jpg
	└── strawberry.jpg
