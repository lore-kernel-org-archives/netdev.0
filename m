From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI:  dev.c change to net_rx_action algorithm.
Date: Sat, 9 Nov 2002 09:41:09 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211090930460.16986-100000@shell.cyberus.ca>
References: <3DCC9D7D.6020005@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DCC9D7D.6020005@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 8 Nov 2002, Ben Greear wrote:

> Btw, and you'll love this one, if I change the priority of the irq thread
> to -18, things get even better ;)

;-> Ok, go ahead and hack the scheduler now.

All, i am saying is that you should stop wildly pointing fingers at a
million things and diagnose what the issue is then come up with a fix;
So far, you have not. It was the rx ring then it is napi/DRR and now it is
the scheduler; and before you find the real cause please stop posting
code like a lunatic.

cheers,
jamal
