From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 3/x: [NETDRV] Add register_ei_netdev
Date: Wed, 02 Jun 2004 16:24:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40BE3778.1020404@pobox.com>
References: <20040313025859.GA8186@gondor.apana.org.au> <405C294D.5040508@pobox.com> <20040520111937.GA21804@gondor.apana.org.au> <20040522074435.GA9628@gondor.apana.org.au> <20040529084109.GA13032@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040529084109.GA13032@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi Jeff:
> 
> Here is the patch that adds register_ei_netdev which lets us get rid of
> some of the duplicated printk's in the 8390 drivers.


Patch looks OK, but I would prefer to reject it, and merge it later when 
an accompanying patch appears using this new function.

	Jeff
