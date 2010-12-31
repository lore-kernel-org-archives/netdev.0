From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: [PATCH 12/15]drivers:media:video:tvp7002.c Typo change diable
	to disable.
Date: Fri, 31 Dec 2010 08:24:59 -0200
Message-ID: <4D1DAF7B.4020504@redhat.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-2-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-3-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-4-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-5-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-6-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-7-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-8-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-9-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-10-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-11-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-12-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-m68k@vger.kernel.org, trivial@kernel.org,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ivtv-devel@ivtvdriver.org,
	spi-devel-general@lists.sourceforge.net, linux-media@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1293750484-1161-12-git-send-email-justinmattock@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Em 30-12-2010 21:08, Justin P. Mattock escreveu:
> The below patch fixes a typo "diable" to "disable". Please let me know if this 
> is correct or not.
> 
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
Acked-by: Mauro Carvalho Chehab <mchehab@redhat.com>
> 
> ---
>  drivers/media/video/tvp7002.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/media/video/tvp7002.c b/drivers/media/video/tvp7002.c
> index e63b40f..c799e4e 100644
> --- a/drivers/media/video/tvp7002.c
> +++ b/drivers/media/video/tvp7002.c
> @@ -789,7 +789,7 @@ static int tvp7002_query_dv_preset(struct v4l2_subdev *sd,
>   * Get the value of a TVP7002 decoder device register.
>   * Returns zero when successful, -EINVAL if register read fails or
>   * access to I2C client fails, -EPERM if the call is not allowed
> - * by diabled CAP_SYS_ADMIN.
> + * by disabled CAP_SYS_ADMIN.
>   */
>  static int tvp7002_g_register(struct v4l2_subdev *sd,
>  						struct v4l2_dbg_register *reg)
