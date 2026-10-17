/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Poster berasal dari host eksternal (tmdb, dst) — lewati optimasi image.
  images: { unoptimized: true },
};

export default nextConfig;
