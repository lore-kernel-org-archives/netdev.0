From: Amy Fong <amy.fong@windriver.com>
Subject: Re: [PATCH] Add Broadcom PHY support
Date: Tue, 19 Sep 2006 09:35:42 -0400 (EDT)
Message-ID: <E1GPflG-0000n7-2o@lucciola>
References: <450F7498.8090504@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751955AbWISNgS@vger.kernel.org>
In-Reply-To: <450F7498.8090504@garzik.org>
To: Jeff Garzik <jeff@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Charset ISO-8859-1 unsupported, converting... ]
> Amy Fong wrote:
> > [PATCH] Add Broadcom PHY support
> > 
> > This patch adds a driver to support the bcm5421s and bcm5461s PHY
> > 
> > Kernel version:  linux-2.6.18-rc6
> > 
> > Signed-off-by: Amy Fong <amy.fong@windriver.com>
> 
> And... where are the users of this phy driver?
> 
> 	Jeff
> 

This phy driver is used by the WRS's sbc8560 (bcm5421s) and sbc843x (bcm5461s) via the gianfar driver.

Amy
