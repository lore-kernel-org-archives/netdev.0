From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ARP problem?
Date: Thu, 17 Oct 2002 12:24:31 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210171217290.3028-100000@l>
References: <E156A23F1885D4119ED800B0D0498A9F02128B94@aimexc07.adaptec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Thompson, Ian" <Ian_Thompson@adaptec.com>
In-Reply-To: <E156A23F1885D4119ED800B0D0498A9F02128B94@aimexc07.adaptec.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 16 Oct 2002, Thompson, Ian wrote:

> I am trying to devlop some code to support an active failover case, so I
> want two seperate devices on the same physical network.  I have seen the

	May be you need support for alternative non-default routes:

http://www.ssi.bg/~ja/#routes

	These patches will make the routing to use the two link
routes for your subnet (not only the first one), I assume you are
worrying about problems with the two links to the hub.

> TIA,
> -ian

Regards

--
Julian Anastasov <ja@ssi.bg>
