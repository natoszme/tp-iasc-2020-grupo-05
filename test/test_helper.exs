# Start ExUnit. seed = 0 makes tests run as they are described (from top to bottom)
ExUnit.configure seed: 0
ExUnit.start()

KV.Bucket.start_link([])