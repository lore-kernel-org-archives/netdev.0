From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 2/9] rfkill: Remove extra blank line
Date: Tue, 9 Feb 2016 09:38:06 +1100
Message-ID: <CAGRGNgXd-sPP-omQ-Vnkfgw7AGWa=8EaRQwL_jkTPnxKfdTSDQ@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com> <1454946096-9752-3-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1454946096-9752-3-git-send-email-jprvita@endlessm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jo=C3=A3o,

On Tue, Feb 9, 2016 at 2:41 AM, Jo=C3=A3o Paulo Rechi Vita <jprvita@gma=
il.com> wrote:
> Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>

Looks sane to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

> ---
>  net/rfkill/core.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
> index ffbc375..56d79cb 100644
> --- a/net/rfkill/core.c
> +++ b/net/rfkill/core.c
> @@ -455,7 +455,6 @@ bool rfkill_get_global_sw_state(const enum rfkill=
_type type)
>  }
>  #endif
>
> -
>  bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
>  {
>         unsigned long flags;
> --
> 2.5.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
