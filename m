From: Ivo Van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 1/2] rt2x00: Fix unspeficied typo
Date: Fri, 24 Jun 2011 09:34:21 +0200
Message-ID: <BANLkTinrzbuM6TvEJkMmQKkwdf=RTSCxuw@mail.gmail.com>
References: <6002eb70809bb1c87c84f32ab4a4f034d2d1ffb5.1308868289.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6002eb70809bb1c87c84f32ab4a4f034d2d1ffb5.1308868289.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 24, 2011 at 12:35 AM, Joe Perches <joe@perches.com> wrote:
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

> ---
> =A0drivers/net/wireless/rt2x00/rt2x00queue.h | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.h b/drivers/net/=
wireless/rt2x00/rt2x00queue.h
> index 167d458..5900474 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00queue.h
> +++ b/drivers/net/wireless/rt2x00/rt2x00queue.h
> @@ -54,7 +54,7 @@
> =A0* @QID_RX: RX queue
> =A0* @QID_OTHER: None of the above (don't use, only present for compl=
eteness)
> =A0* @QID_BEACON: Beacon queue (value unspecified, don't send it to d=
evice)
> - * @QID_ATIM: Atim queue (value unspeficied, don't send it to device=
)
> + * @QID_ATIM: Atim queue (value unspecified, don't send it to device=
)
> =A0*/
> =A0enum data_queue_qid {
> =A0 =A0 =A0 =A0QID_AC_VO =3D 0,
> --
> 1.7.6.rc1
>
>
