From: Mauro Carvalho Chehab <maurochehab@gmail.com>
Subject: Re: [PATCH 11/15]drivers:media:video:cx18:cx23418.h Typo change diable
 to disable.
Date: Fri, 31 Dec 2010 08:23:41 -0200
Message-ID: <4D1DAF2D.5070604@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com> <1293750484-1161-2-git-send-email-justinmattock@gmail.com> <1293750484-1161-3-git-send-email-justinmattock@gmail.com> <1293750484-1161-4-git-send-email-justinmattock@gmail.com> <1293750484-1161-5-git-send-email-justinmattock@gmail.com> <1293750484-1161-6-git-send-email-justinmattock@gmail.com> <1293750484-1161-7-git-send-email-justinmattock@gmail.com> <1293750484-1161-8-git-send-email-justinmattock@gmail.com> <1293750484-1161-9-git-send-email-justinmattock@gmail.com> <1293750484-1161-10-git-send-email-justinmattock@gmail.com> <1293750484-1161-11-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, linux-m68k@lists.linux-m68k.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ivtv-devel@ivtvdriver.org, linux-media@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1293750484-1161-11-git-send-email-justinmattock@gmail.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em 30-12-2010 21:08, Justin P. Mattock escreveu:
> The below patch fixes a typo "diable" to "disable". Please let me know if this 
> is correct or not.
> 
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
Acked-by: Mauro Carvalho Chehab <mchehab@redhat.com>
> 
> ---
>  drivers/media/video/cx18/cx23418.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/media/video/cx18/cx23418.h b/drivers/media/video/cx18/cx23418.h
> index 2c00980..7e40035 100644
> --- a/drivers/media/video/cx18/cx23418.h
> +++ b/drivers/media/video/cx18/cx23418.h
> @@ -177,7 +177,7 @@
>     IN[0] - Task handle.
>     IN[1] - luma type: 0 = disable, 1 = 1D horizontal only, 2 = 1D vertical only,
>  		      3 = 2D H/V separable, 4 = 2D symmetric non-separable
> -   IN[2] - chroma type: 0 - diable, 1 = 1D horizontal
> +   IN[2] - chroma type: 0 - disable, 1 = 1D horizontal
>     ReturnCode - One of the ERR_CAPTURE_... */
>  #define CX18_CPU_SET_SPATIAL_FILTER_TYPE     	(CPU_CMD_MASK_CAPTURE | 0x000C)
>  
