From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: 16 Jan 2005 12:37:00 -0500
Message-ID: <1105897020.1091.736.camel@jzny.localdomain>
References: <20050112222437.GC14280@xi.wantstofly.org>
	 <Pine.LNX.4.61.0501130944270.19573@netcore.fi>
	 <20050113092351.GA23170@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pekka Savola <pekkas@netcore.fi>, netdev@oss.sgi.com, shemminger@osdl.org,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050113092351.GA23170@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-01-13 at 04:23, Lennert Buytenhek wrote:
> On Thu, Jan 13, 2005 at 09:49:55AM +0200, Pekka Savola wrote:
> 
> > Is there a particular reason why GRE tunnel is not sufficient? 
> 
> No particular reason, apart from not being aware that GRE provides
> this functionality.

True that GRE can do all this (and they have thought out well the
broadcasting etc) but i dont think it will harm to push this into the
kernel if some odd OS like openbsd supports it. 

cheers,
jamal
