From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 0/5] ppp,pppoe,pppol2tp -- introduce namespace
	functionality v2
Date: Tue, 20 Jan 2009 17:17:28 +0300
Message-ID: <20090120141728.GA14560@localhost>
References: <4975dc11.0c07560a.7a93.ffff9782@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, jchapman@katalix.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org, xemul@openvz.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762900AbZATOSU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4975dc11.0c07560a.7a93.ffff9782@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Cyrill Gorcunov - Tue, Jan 20, 2009 at 05:05:10PM +0300]
| Hi, here is a series of patches in hope to bring
| net-namespace functionality for PPP, PPPoE, PPPoL2TP
| protocols.
| 
| I've tested plain PPP virtualization and it worked
| for me. Quite may thanks to James Chapman who
| was testing PPPoL2TP for me, thanks a lot again
| James!
| 
| Please review and test if possible. I do really
| appreciate _any_ kind of feedback. Thanks!
| 
| I didn't put Ack I got on previous series since it's
| a bit new (though PPPoE didn't changed but anyway)
| 
| The patches are on top of net-2.6 commit
| 
| commit f4895b8bc83a22a36446c4aee277e1750fcc6a18
| Author: Inaky Perez-Gonzalez <inaky@linux.intel.com>
| Date:   Mon Jan 19 13:19:30 2009 +0000
| 
|     wimax/i2400m: error paths that need to free an skb should use kfree_skb()
| 
| 	Cyrill
| -- 
| 

Ugh, sorry, quilt again screwed my post-date :(
It seems I defenitely has to switch to git.
		- Cyrill -
