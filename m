From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: Fri, 10 Sep 2004 02:40:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910024030.28b7c66c@linux.site>
References: <20040909164834.GB18994@postel.suug.ch>
	<20040909103344.5a448b01.davem@davemloft.net>
	<20040909175411.GB19155@postel.suug.ch>
	<20040910.103341.28767986.yoshfuji@wide.ad.jp>
	<20040910092948.GB19930@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@wide.ad.jp>,
        davem@davemloft.net, hadi@cyberus.ca, eric.lemoine@gmail.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040910092948.GB19930@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Unless there is some compelling reason, I think that keeping the old ioctl
interface for a least a year until the kernel changes become more ubiquitous.
