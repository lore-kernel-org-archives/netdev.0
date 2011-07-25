From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/7] More sane neigh infrastructure
Date: Mon, 25 Jul 2011 15:49:39 -0700
Message-ID: <CAL1RGDXkUj0N5M4c_bpgzC3qM2Ge9Y3n2C0TTRUksx3DeD7D3w@mail.gmail.com>
References: <20110725.030109.1723861338142084129.davem@davemloft.net>
 <CAG4TOxOv1WsgfRXxrBWWq-+9ee3apEE0B_Onn+JB=tEEuOhhxg@mail.gmail.com> <20110725.141041.1092565620930748250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110725.141041.1092565620930748250.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 25, 2011 at 2:10 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> So call the normal ARP neigh solicit stuff in your neigh ops, and do
> your local stuff there as well.
>
> See if you can make it work.

Makes sense, I'll poke at that.  Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
