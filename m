From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [2.6 patch] wrong firmware location in IPW2100 Kconfig entry
Date: Mon, 06 Feb 2006 15:02:19 +0800
Message-ID: <1139209340.4784.11.camel@debian.sh.intel.com>
References: <20060131161124.GA3986@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	Jesper Juhl <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, jketreno@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751054AbWBFHIt@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060131161124.GA3986@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-01-31 at 17:11 +0100, Adrian Bunk wrote:
> From: Jesper Juhl <jesper.juhl@gmail.com>
> 
> Firmware should go into /lib/firmware, not /etc/firmware.
> 
> Found by Alejandro Bonilla.
> 
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Acked-by: Zhu Yi <yi.zhu@intel.com>

Thanks,
-yi
