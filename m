From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [RFC 2/3] RDMA/cma: Add support for netlink statistics export
Date: Thu, 19 May 2011 19:03:26 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373010008@ORSMSX101.amr.corp.intel.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
 <1305303525-11113-3-git-send-email-roland@kernel.org>
 <1828884A29C6694DAF28B7E6B8A82373F428@ORSMSX101.amr.corp.intel.com>
 <BANLkTin1uVyrzdn_030bGmC=QHtfkvOTNA@mail.gmail.com>
 <1828884A29C6694DAF28B7E6B8A82373FF9E@ORSMSX101.amr.corp.intel.com>
 <BANLkTimahta6QYrjTE5+DmN6RZXY_c72=Q@mail.gmail.com>
 <BANLkTimjhAVfpJQX-PshVBgcshzfh-taRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTimjhAVfpJQX-PshVBgcshzfh-taRw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> And actually looking at https://patchwork.kernel.org/patch/90204/
> it looks reasonable to merge now... or I could just use
> cma_is_ud_ps() in the netlink stuff.
> 
> I'm inclined to just take your patch now if that makes sense to you
> (it looks pretty independent of everything else)
> 
> Is that the latest version in patchwork?

The only difference that I see between that patch and what's in my tree are the line numbers.  The patch looks safe enough to me to go in separately from anything else.  Thanks

- Sean
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
