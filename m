From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Sis900 and VLAN 8021q.o incompatible/MTU troubles
Date: Thu, 12 May 2005 22:37:10 +0200
Message-ID: <20050512203710.GA30261@electric-eye.fr.zoreil.com>
References: <200505120743.j4C7hWKI011583@l0p.le-gobw.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Axel Reinhold <Axel.Reinhold@le-gobw.de>
Content-Disposition: inline
In-Reply-To: <200505120743.j4C7hWKI011583@l0p.le-gobw.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Axel Reinhold <Axel.Reinhold@le-gobw.de> :
[...]
> my sis900 is running fine in standard mode. Together with 8021q.o
> i get all kinds of troubles - for example samba is no more working at
> all - without vlan everything is fine - with vlans everything basically
> works - but only to a certain point, then it screws up.

It can help if you provide:
- the kernel revision;
- some vlan context (commands issued ? vlan only or mixed config ?);
- the range of working size for simple ping.

--
Ueimor
