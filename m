From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/8] Intel I/O Acceleration Technology (I/OAT)
Date: Fri, 03 Mar 2006 17:27:22 -0500
Message-ID: <4408C2CA.5010909@garzik.org>
References: <20060303214036.11908.10499.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751734AbWCCW1Z@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060303214036.11908.10499.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech wrote:
> This patch series is the first full release of the Intel(R) I/O
> Acceleration Technology (I/OAT) for Linux.  It includes an in kernel API
> for offloading memory copies to hardware, a driver for the I/OAT DMA memcpy
> engine, and changes to the TCP stack to offload copies of received
> networking data to application space.
> 
> These changes apply to DaveM's net-2.6.17 tree as of commit
> 2bd84a93d8bb7192ad8c23ef41008502be1cb603 ([IRDA]: TOIM3232 dongle support)
> 
> They are available to pull from
> 	git://198.78.49.142/~cleech/linux-2.6 ioat-2.6.17
> 
> There are 8 patches in the series:
> 	1) The memcpy offload APIs and class code
> 	2) The Intel I/OAT DMA driver (ioatdma)

Patch #2 didn't make it.  Too big for the list?

	Jeff
