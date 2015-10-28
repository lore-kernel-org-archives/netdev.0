From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] seccomp, ptrace: add support for dumping
 seccomp filters
Date: Tue, 27 Oct 2015 19:55:57 -0700 (PDT)
Message-ID: <20151027.195557.2179752995547193374.davem@davemloft.net>
References: <1445905439-25449-1-git-send-email-tycho.andersen@canonical.com>
	<1445905439-25449-2-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445905439-25449-2-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Tue, 27 Oct 2015 09:23:59 +0900

> This patch adds support for dumping a process' (classic BPF) seccomp
> filters via ptrace.

Applied, thanks.
