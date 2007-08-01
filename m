From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Removing the prism54 module
Date: Tue, 31 Jul 2007 21:20:57 -0400
Message-ID: <43e72e890707311820h59eebf6raf5b77058e2d23dc@mail.gmail.com>
References: <20070728224008.782a3be6@ed.anywhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Edward Ando" <edwardando-dbx96nzIXN7OeuqD6ShaSA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070728224008.782a3be6-L01rVeg4zJJ+2kGCxyASIg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 7/28/07, Edward Ando <edwardando-dbx96nzIXN7OeuqD6ShaSA@public.gmane.org> wrote:
> Dear All,
> I am trying to set up software suspend 2 (TuxOnIce now it seems). This
> has decided it wants to remove the prism54 module before starting the
> hibernate process.
>
> When it tries to do this, (or when I manually do: "ifconfig eth1
> down"), I start getting these messages on all terminals, ad infinitum:
>
> kernel: unregister_netdevice: waiting for eth1 to become free. Usage
> count = 4

Hmm... can you show lsmod output please?

  Luis
