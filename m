From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/3] wireless: rtlwifi: throw away MAC_FMT and use %pM
 instead
Date: Wed, 20 Jul 2011 10:47:05 -0500
Message-ID: <4E26F879.8010601@lwfinger.net>
References: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/2011 08:34 AM, Andy Shevchenko wrote:
> Signed-off-by: Andy Shevchenko<andriy.shevchenko@linux.intel.com>
> Cc: Larry Finger<Larry.Finger@lwfinger.net>
> ---
>   drivers/net/wireless/rtlwifi/base.c         |   11 +++++------
>   drivers/net/wireless/rtlwifi/cam.c          |    4 ++--
>   drivers/net/wireless/rtlwifi/core.c         |    6 +++---
>   drivers/net/wireless/rtlwifi/debug.h        |    5 -----
>   drivers/net/wireless/rtlwifi/rtl8192ce/hw.c |    2 +-
>   drivers/net/wireless/rtlwifi/rtl8192de/hw.c |    2 +-
>   drivers/net/wireless/rtlwifi/rtl8192se/hw.c |    2 +-
>   7 files changed, 13 insertions(+), 19 deletions(-)

ACK.  Thanks for the patch.

Larry
