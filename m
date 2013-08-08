From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Patch net-next v2 5/8] sunrpc: use generic union inet_addr
Date: Thu, 08 Aug 2013 09:37:30 +0800
Message-ID: <1375925850.19907.5.camel@cr0>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
	 <1375427674-21735-6-git-send-email-amwang@redhat.com>
	 <20130802093625.2c70a330@tlielax.poochiereds.net>
	 <1375672445.32485.8.camel@cr0>
	 <20130806062801.67714276@tlielax.poochiereds.net>
	 <1375878446.11370.36.camel@cr0>
	 <20130807092123.451e93db@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130807092123.451e93db-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-07 at 09:21 -0400, Jeff Layton wrote:
> Ok, good point. That does look cleaner. I'd still like to see the rpc_*
> wrappers go away, but that can be done later.
> 

I will move the wrappers to generic since several people asked.


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
