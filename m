From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6.10-rc1] remove NET_HW_FLOWCONTROL
Date: 25 Oct 2004 18:36:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098743771.1043.11.camel@jzny.localdomain>
References: <20041025202042.GA4930@infradead.org>
	 <417D6067.3010102@pobox.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <417D6067.3010102@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

nuke it.
I only know of one user of it in 2.4.x. If possible leave 2.4.x alone.

cheers,
jamal

On Mon, 2004-10-25 at 16:21, Jeff Garzik wrote:
> Arjan van de Ven wrote:
> > CONFIG_NET_HW_FLOWCONTROL is entirely unused now, and superceded by NAPI in
> > practice, so remove the dead code
> 
> Ok with me.  Jamal?
> 
> 	Jeff
> 
> 
> 
