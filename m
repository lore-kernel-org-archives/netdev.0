From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: 16 Jan 2005 15:05:06 -0500
Message-ID: <1105905906.1097.860.camel@jzny.localdomain>
References: <20050112222437.GC14280@xi.wantstofly.org>
	 <Pine.LNX.4.61.0501130944270.19573@netcore.fi>
	 <20050113092351.GA23170@xi.wantstofly.org>
	 <1105897020.1091.736.camel@jzny.localdomain>
	 <20050116190227.GC21870@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pekka Savola <pekkas@netcore.fi>, netdev@oss.sgi.com, shemminger@osdl.org,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050116190227.GC21870@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-16 at 14:02, Lennert Buytenhek wrote:

> Apparently they mis-read the RFC and write the etherip header as 0x0300
> instead of 0x3000 (they have the version nibble in the wrong place.)  This
> would likely prevent interoperability.

Thinking about it a bit - you should be able to break yours to do 0x0300
to test with them ;->

cheers,
jamal
