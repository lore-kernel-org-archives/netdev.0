From: Arjen Verweij <A.Verweij2@ewi.tudelft.nl>
Subject: wol support in forcedeth v25
Date: Mon, 19 Apr 2004 22:11:10 +0200 (METDST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GHP.4.44.0404192205070.11806-100000@elektron.its.tudelft.nl>
Reply-To: a.verweij@student.tudelft.nl
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: adq@lidskialf.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Is the wol support in forcedeth v25 complete yet? I was trying it with the
2.6.5 kernel it came with, tried the new forcedeth driver with a 2.6.3
kernel (because firewire seems broken in 2.6.5) however, my box will not
wake up as of yet.

According to the source there is a FIXME with a comment about powering
down the NIC. Does this mean that support for wol is incomplete for now?
Mind you, I am just curious, this is in no way meant as criticism.

On another note, Carl-Daniel mentioned that DEV_NEED_TIMERIRQ might be
removed from future releases. Is this still the case? Feedback would be
much appreciated, so I can keep my humble audience up to date on what's
going on at the wol front.

Thank you guys for your excellent work,

Arjen
http://atlas.et.tudelft.nl/verwei90/nforce2/index.html
