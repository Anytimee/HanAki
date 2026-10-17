"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { clearToken, setStoredUser, setToken } from "@/lib/auth";
import { apiErrorMessage } from "@/lib/api";
import { useLogin } from "@/hooks/use-api";

const loginSchema = z.object({
  email: z.string().trim().email("Email tidak valid"),
  password: z.string().min(1, "Password wajib diisi"),
});

type LoginValues = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const router = useRouter();
  const login = useLogin();

  const form = useForm<LoginValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: "", password: "" },
  });

  const onSubmit = (values: LoginValues) => {
    login.mutate(values, {
      onSuccess: (data) => {
        if (data.user.role !== "ADMIN") {
          clearToken();
          toast.error("Akun ini bukan ADMIN. Akses panel ditolak.");
          return;
        }
        setToken(data.token);
        setStoredUser({
          id: data.user.id,
          email: data.user.email,
          role: data.user.role,
        });
        toast.success(`Selamat datang, ${data.user.email}`);
        router.replace("/");
      },
      onError: (error) => toast.error(apiErrorMessage(error)),
    });
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-zinc-950 p-4">
      <Card className="w-full max-w-sm border-zinc-800 bg-zinc-900">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold tracking-tight">
            HanAki <span className="text-zinc-400">Admin</span>
          </CardTitle>
          <CardDescription className="text-zinc-400">
            Masuk dengan akun ADMIN untuk mengelola konten.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form
              onSubmit={form.handleSubmit(onSubmit)}
              className="space-y-4"
              noValidate
            >
              <FormField
                control={form.control}
                name="email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Email</FormLabel>
                    <FormControl>
                      <Input
                        type="email"
                        placeholder="admin@hanaki.com"
                        autoComplete="email"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Password</FormLabel>
                    <FormControl>
                      <Input
                        type="password"
                        placeholder="••••••••"
                        autoComplete="current-password"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <Button
                type="submit"
                className="w-full"
                disabled={login.isPending}
              >
                {login.isPending && (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                )}
                Masuk
              </Button>
            </form>
          </Form>
        </CardContent>
      </Card>
    </main>
  );
}
