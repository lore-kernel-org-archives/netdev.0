From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Sat, 25 Feb 2006 15:19:40 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0602251518200.31692@yvahk01.tjqt.qr>
References: <43FF88E6.6020603@linux.intel.com> <20060225084139.GB22109@infradead.org>
 <200602250549.47547.gene.heskett@verizon.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	NetDev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	okir@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932372AbWBYOT6@vger.kernel.org>
To: gene.heskett@verizononline.net
In-Reply-To: <200602250549.47547.gene.heskett@verizon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>If the modules crc changes, 
>it must do an instant disable of the transmitter functions and exit or 
>crash, thereby precluding any 'hot rodding' of the chipset.
>
Would not it be easiest to have the chipset enforce the acceptable bands? 
So that software can't switch the chipset to 1337 GHz no matter how hard 
you forward/reverse-engineer it.


Jan Engelhardt
-- 
