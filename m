From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 7 Jan 2010 19:01:14 +0100
Message-ID: <20100107180114.GB3088@del.dom.local>
References: <4B451C31.3000309@majjas.com>
 <4B454A16.3030909@majjas.com>
 <4B455C62.6030504@majjas.com>
 <20100106205343.5460d658@nehalam>
 <4B4571D5.30002@majjas.com>
 <4B457711.1040008@majjas.com>
 <4B458B36.6050509@majjas.com>
 <20100107074756.GB6258@ff.dom.local>
 <4B459368.2000503@majjas.com>
 <4B45F841.8030407@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752984Ab0AGSBZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B45F841.8030407@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2010 at 10:05:37AM -0500, Michael Breuer wrote:
> Bad news - crashed about an hour after I wrote this email - under
> load - same crash as before. Network watchdog... lots of attempts to
> reset the adapter... then hw watchdog rebooted the system.

It's a pity. Anyway, I'd be still interested in CONFIG_PACKET_MMAP off
if you find time.

Jarek P.
