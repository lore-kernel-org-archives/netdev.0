From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Sis900 bug fixes 3/4
Date: Wed, 19 May 2004 19:58:08 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40ABF490.80901@pobox.com>
References: <20040518120237.GC23565@picchio.gall.it> <20040518123020.GF23565@picchio.gall.it> <20040519142852.GC798@picchio.gall.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com, Dominik Karall <dominik.karall@gmx.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264653AbUESX6Y@vger.kernel.org>
To: Daniele Venzano <webvenza@libero.it>, Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040519142852.GC798@picchio.gall.it>
List-Id: netdev.vger.kernel.org

Daniele Venzano wrote:
> http://teg.homeunix.org/sis900.html
> 
> They are:
> sis900-maintainers

Let's hold off on this for now...  we can commit this patch anytime, and 
there is no harm in being "unofficial maintainer" for a while.


> sis900-isa-bridge-id

applied, with modifications, to netdev-2.6


> sis900-phy-detection (attached below)

I'd like to wait until my netdev-2.6 changes (just pushed to their 
public BK home, bk://gkernel.bkbits.net/netdev-2.6) are pulled by 
Andrew, and incorporated into the update of his -mm tree.

This patch will likely need some rediffing.


> sis900-header-cleanups

applied, with modifications, to netdev-2.6

Also I applied the sis900-detach found on the web page.

	Jeff
