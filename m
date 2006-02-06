From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [2.6 patch] let IPW2{1,2}00 select IEEE80211
Date: Mon, 06 Feb 2006 15:02:29 +0800
Message-ID: <1139209350.4784.13.camel@debian.sh.intel.com>
References: <20060205151322.GE5271@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Niehusmann <jan@gondor.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751024AbWBFHJG@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060205151322.GE5271@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-02-05 at 16:13 +0100, Adrian Bunk wrote:
> From: Jan Niehusmann <jan@gondor.com>
> 
> This patch makes the IPW2100 and IPW2200 options available in
> the configuration menu even if IEEE80211 has not been selected before.
> This behaviour is more intuitive for people which are not familiar with
> the driver internals.
> The suggestion for this change was made by Alejandro Bonilla Beeche.
> 
> Signed-off-by: Jan Niehusmann <jan@gondor.com>
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Acked-by: Zhu Yi <yi.zhu@intel.com>

Thanks,
-yi
