From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6 PKT_SCHED]: Fix overflow on 64bit in times reported
	to userspace by tc actions
Date: 21 Nov 2004 12:47:13 -0500
Message-ID: <1101059233.1093.151.camel@jzny.localdomain>
References: <41908D1D.50405@trash.net>
	 <20041111150314.576ce699.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041111150314.576ce699.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-11-11 at 18:03, David S. Miller wrote:


> I agree, and since Jamal also ACK'd it, I've applied
> this patch.
> 

Ive just tested the other patch from Patrick and it looks fine. Will put
it through more testing later to test the different code paths; basics
look good - so it should be fine to go in.  
Patrick are you going to work on the other cleanups you were thuinking
of? ( etc)

cheers,
jamal
