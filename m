From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patches] invalid nh.raw use after free
Date: Wed, 16 Jul 2003 10:09:02 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307161007070.1921-100000@l>
References: <20030715191709.1e0c6427.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030715191709.1e0c6427.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 15 Jul 2003, David S. Miller wrote:

> > sure if there are more instances), where pointers remain to refer to
> > freed skbs. For 2.5 and 2.4.
>
> Good catch, I'll apply this.

	Please, apply also to 2.2

Regards

--
Julian Anastasov <ja@ssi.bg>
