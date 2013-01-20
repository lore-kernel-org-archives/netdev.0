From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 15/21] NTB: Update Version
Date: Sun, 20 Jan 2013 15:47:14 -0800
Message-ID: <20130120234714.GA21708@kroah.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-16-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358586155-23322-16-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 19, 2013 at 02:02:29AM -0700, Jon Mason wrote:
> Update NTB version to 0.25
> 
> Signed-off-by: Jon Mason <jon.mason@intel.com>
> ---
>  drivers/ntb/ntb_hw.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> index b792ccd..df86882 100644
> --- a/drivers/ntb/ntb_hw.c
> +++ b/drivers/ntb/ntb_hw.c
> @@ -56,7 +56,7 @@
>  #include "ntb_regs.h"
>  
>  #define NTB_NAME	"Intel(R) PCI-E Non-Transparent Bridge Driver"
> -#define NTB_VER		"0.24"
> +#define NTB_VER		"0.25"

I'm not objecting to this, but in the end, does it really matter?  Why
not just stick with whatever kernel version you are using?  Keeping this
up to date is going to be hard over the long haul, right?

thanks,

greg k-h
