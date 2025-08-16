var builder = WebApplication.CreateBuilder(args);
builder.Services.AddOpenApi();
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}
app.UseHttpsRedirection();

app.MapGet("/", () =>
{
    return TypedResults.Ok("Hello World - V2");
})
.WithName("HelloWorld");

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.Run();