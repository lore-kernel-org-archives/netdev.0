From: Anton Blanchard <anton@samba.org>
Subject: [cryptic-lkml@bloodletting.com: Re: Testing Dual Ethernet via Loopback]
Date: Sun, 25 Apr 2004 11:17:06 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040425011706.GD20714@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ja@ssi.bg
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

We have found Julian Anastasov's send-to-self patch extremely useful in
the lab. There seem to be a number of other people who agree, what are
the chances of getting it merged into 2.6?

Ive got a version rediffed against recent BK if required.

Anton

----- Forwarded message from Nick Popoff <cryptic-lkml@bloodletting.com> -----

From: Nick Popoff <cryptic-lkml@bloodletting.com>
To: Anton Blanchard <anton@samba.org>, linux-kernel@vger.kernel.org
Subject: Re: Testing Dual Ethernet via Loopback

On Fri, 23 Apr 2004, Anton Blanchard wrote:
> Sounds like you need the send-to-self patch:
> http://www.ssi.bg/~ja/
> We've been using it a lot in the lab, it works well.

I tried this out yesterday with Linux 2.6.5 at it worked like a charm.  Thank 
you to everyone who replied with solutions and to the author of this patch!  

I thought the idea of pinging an invalid IP from one interface while snooping 
with ethereal on the other interface was very clever, but hard to use for 
performance testing. :-)

----- End forwarded message -----
