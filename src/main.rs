use bollard::{image::BuildImageOptions, Docker};
use clap::{arg, command, Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
	// /// Name of the person to greet
	// #[arg(short, long)]
	// name: String,

	// /// Number of times to greet
	// #[arg(short, long, default_value_t = 1)]
	// count: u8,

	#[command(subcommand)]
	commands: Option<Commands>
}


#[derive(Subcommand, Debug)]
enum Commands {
	/// does testing things
	Test {
		/// lists test values
		#[arg(short, long)]
		list: bool,
	},
	/// Creates new development environment
	New {
		/// URL or SSH of the git repository to clone
		#[arg(short, long)]
		repo: String
	}	
}

#[tokio::main]
async fn main() {
	let args = Args::parse();

	let docker = Docker::connect_with_socket_defaults().unwrap();

	// You can check for the existence of subcommands, and if found use their
	// matches just as you would the top level cmd
	match &args.commands {
		Some(Commands::Test { list }) => {
			if *list {
				println!("Printing testing lists...");
			} else {
				println!("Not printing testing lists...");
			}
		},
		Some(Commands::New { repo }) => {
				println!("Cloning repo {}...", *repo);
				&docker.build_image(BuildImageOptions {
					dockerfile: "alpine.dockerfile",
					rm: true,
					..Default::default()
				}, None, None)
	
		}
		None => {}
	}

	// for _ in 0..args.count {
	//     println!("Hello {}!", args.name)
	// }
}

// #[tokio::main]
// async fn main() {
//     let docker = Docker::connect_with_socket_defaults().unwrap();

//     let images = &docker.list_images(Some(ListImagesOptions::<String> {
//         all: true,
//         ..Default::default()
//     })).await.unwrap();

//     for image in images {
//         println!("-> {:?}", image);
//     }
// }



