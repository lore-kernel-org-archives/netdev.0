From: Geoff Levand <geoffrey.levand@am.sony.com>
Subject: Re: [PATCH v2 5/7] drivers/net: Remove local #define IW_IOCTL, use
 STD_IW_HANDLER
Date: Wed, 31 Mar 2010 10:55:15 -0700
Message-ID: <4BB38C83.9090808@am.sony.com>
References: <cover.1268892663.git.joe@perches.com> <696c60e097ff35aeb2d746d1a0edf167514f2b61.1268892664.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Zhu Yi <yi.zhu@intel.com>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	"cbe-oss-dev@ozlabs.org" <cbe-oss-dev@ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <696c60e097ff35aeb2d746d1a0edf167514f2b61.1268892664.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 03/17/2010 11:21 PM, Joe Perches wrote:
> Use #define STD_IW_HANDLER from wireless.h instead
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ps3_gelic_wireless.c       |   35 +++++++-------
>  drivers/net/wireless/ipw2x00/ipw2200.c |   83 ++++++++++++++++----------------
>  2 files changed, 58 insertions(+), 60 deletions(-)

Sorry for the delay.  This looks fine for the PS3.

Acked-by: Geoff Levand <geoff@infradead.org>
