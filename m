From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6 PKT_SCHED]: Fix overflow on 64bit in times reported
	to userspace by tc actions
Date: 22 Nov 2004 08:24:34 -0500
Message-ID: <1101129873.1093.300.camel@jzny.localdomain>
References: <41908D1D.50405@trash.net>
	 <20041111150314.576ce699.davem@davemloft.net>
	 <1101059233.1093.151.camel@jzny.localdomain>  <41A1C99B.6010202@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41A1C99B.6010202@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-11-22 at 06:12, Patrick McHardy wrote:
> jamal wrote:
> 
> >Patrick are you going to work on the other cleanups you were thuinking
> >of? ( etc)
> >
> I will send you a batch of patches in one or two weeks, right now I'm
> waiting for you to ACK the tc_action_init patch so I can resync my
> tree with Dave's.

I think thats the one I am acking, no? Can you resend it just to be
sure. Note that i had no issues with any of the other patches (other
than one i explicitly flagged to test).

cheers,
jamal
