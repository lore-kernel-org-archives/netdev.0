From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 1/2] net: Fix the condition passed to sk_wait_event()
Date: Sat, 2 Oct 2010 16:54:23 -0700 (PDT)
Message-ID: <970819.25375.qm@web53706.mail.re2.yahoo.com>
References: <20101002.132659.71124680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101002.132659.71124680.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,
     I had done the exercise of sending the patch to myself and applyin=
g it (copy-pasting just the patch). One thing that I see is the long li=
ne in the description. If you are referring to that, I've fixed it and =
submitted it again. If not this, I'm at loss.

Thanks,
Tomar

--- On Sun, 3/10/10, David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Subject: Re: [PATCH 1/2] net: Fix the condition passed to sk_wait_eve=
nt()
> To: tomer_iisc@yahoo.com
> Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
> Date: Sunday, 3 October, 2010, 1:56
>=20
> Your patch is still corrupted, your email client is
> splitting up
> long lines.
>=20
> Please, save us a lot of time by test emailing the patch to
> yourself,
> and then trying to apply the patch as you receive it.=A0
> Do this until
> you're fixed all of the formatting problems and then you
> can send it
> here.
>=20
> Do not resend the patch by simply replying again to this
> thread,
> send a fresh posting so that "Re: " doesn't show up in the
> subject
> and this way I can apply it directly without any editing.
>=20
> Thank you.
>=20


     =20
