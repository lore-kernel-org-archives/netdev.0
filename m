From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH V2 net-next 3/3] bnx2x: Use pr_fmt and message
 logging cleanups
Date: Wed, 17 Aug 2011 16:42:28 +0300
Message-ID: <1313588549.7266.9.camel@lb-tlvb-eilong.il.broadcom.com>
References: <cover.1313360100.git.joe@perches.com>
 <2d33739418a06602c817d002b30fedd57cbe5f11.1313360101.git.joe@perches.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2d33739418a06602c817d002b30fedd57cbe5f11.1313360101.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-08-14 at 15:16 -0700, Joe Perches wrote:
> Add pr_fmt(fmt) KBUILD_MODNAME ": " to prefix messages with "bnx2x: ".
> Remove #define DP_LEVEL and use pr_notice.
> Repeating KERN_<LEVEL> isn't necessary in multi-line printks.
> printk macro neatening, use fmt and ##__VA_ARGS__.
> Coalesce long formats.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>
