From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 6/7] bpf: allow eBPF programs to use maps
Date: Sun, 16 Nov 2014 16:34:15 -0500 (EST)
Message-ID: <20141116.163415.1667397687779909689.davem@davemloft.net>
References: <1415929010-9361-7-git-send-email-ast@plumgrid.com>
	<20141116.140422.570375628237589645.davem@davemloft.net>
	<CAMEtUuwrST6wGnBU6UU2NYEubskHYf1XZmZQpkgM+cUc8YD9OA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuwrST6wGnBU6UU2NYEubskHYf1XZmZQpkgM+cUc8YD9OA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Sun, 16 Nov 2014 13:24:53 -0800

> The requirement that _unprivileged_ programs should
> not be able to pass all these pointers back to user is
> well understood and was discussed in detail several
> month back. It's verifier that will prevent leaking of
> kernel addresses.

Ok, fair enough.
