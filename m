From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 2/2] Ethernet driver for the WIZnet W5100 chip
Date: Sat, 31 Mar 2012 12:24:53 +0200
Message-ID: <1333189493.2325.3392.camel@edumazet-glaptop>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru>
	 <1333090806-27988-2-git-send-email-msink@permonline.ru>
	 <1333099431.19659.15.camel@edumazet-laptop>
	 <4F76D3E5.6050605@permonline.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F76D3E5.6050605@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-03-31 at 15:52 +0600, Mike Sinkovsky wrote:


> Maybe, but I cannot test this, sorry - when I set breakpoint on this 
> branch - it never triggered, on all my tests on all boards.
> Appears that my processor is too slow and cannot feed packets fast enough.

Really ?

A pktgen script should certainly hit your NIC limit, unless this is a
100Gbit link ...
