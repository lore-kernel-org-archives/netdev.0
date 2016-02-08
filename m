From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] rfkill: Improve documentation language
Date: Tue, 9 Feb 2016 09:37:32 +1100
Message-ID: <CAGRGNgX7ANq_dTSkRCqnU2H5DQsLCf5Ni7M-n7Z_RSieOf=mOw@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com> <1454946096-9752-2-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454946096-9752-2-git-send-email-jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jo=C3=A3o,

On Tue, Feb 9, 2016 at 2:41 AM, Jo=C3=A3o Paulo Rechi Vita <jprvita@gma=
il.com> wrote:
> Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
>  net/rfkill/core.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
> index a805831..ffbc375 100644
> --- a/net/rfkill/core.c
> +++ b/net/rfkill/core.c
> @@ -282,8 +282,8 @@ static void rfkill_set_block(struct rfkill *rfkil=
l, bool blocked)
>         spin_lock_irqsave(&rfkill->lock, flags);
>         if (err) {
>                 /*
> -                * Failed -- reset status to _prev, this may be diffe=
rent
> -                * from what set set _PREV to earlier in this functio=
n
> +                * Failed -- reset status to _PREV, which may be diff=
erent
> +                * from what we have set _PREV to earlier in this fun=
ction
>                  * if rfkill_set_sw_state was invoked.
>                  */
>                 if (rfkill->state & RFKILL_BLOCK_SW_PREV)
> --
> 2.5.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
