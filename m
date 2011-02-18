From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH v2 0/5] Panda: Support for WLAN on WL127x
Date: Thu, 17 Feb 2011 16:03:54 -0800
Message-ID: <20110218000353.GO20795@atomide.com>
References: <1297759236-25323-1-git-send-email-panduranga_mallireddy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: coelho@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-mmc@vger.kernel.org, ohad@wizery.com, benzyg@ti.com,
	pradeepgurumath@ti.com, vishalm@ti.com, x-boudet@ti.com,
	naveen_jain@ti.com, pavan_savoy@ti.com, manjunatha_halli@ti.com,
	cjb@laptop.org
To: Panduranga Mallireddy <panduranga_mallireddy@ti.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1297759236-25323-1-git-send-email-panduranga_mallireddy@ti.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Panduranga Mallireddy <panduranga_mallireddy@ti.com> [110215 00:13]:
> Fixes from V1:
> 1. Removing the pull up of WLAN IRQ line, since it is always held up by wl127x device.
> 
> Adding support for WLAN on Panda board using wl12xx and mac80211 drivers

Thanks, adding these to devel-board for the upcoming merge window.

Tony
