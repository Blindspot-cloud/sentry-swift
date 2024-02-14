const port = 9999;

const handler = async (request: Request): Promise<Response> => {
    console.log("-------");
    console.log(await request.text());
    console.log("-------");

    return new Response(JSON.stringify({
        id: "433ea1baec3c44d1aa99a600e06ec7aa"
    }), { status: 200 });
};

console.log(`HTTP server running. Access it at: http://localhost:${port}/`);
Deno.serve({ port }, handler);