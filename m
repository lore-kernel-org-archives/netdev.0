From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH v2 net-next af-packet 0/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Tue, 21 Jun 2011 23:02:11 -0400
Message-ID: <BANLkTimisxLVdYJTK1NcR1vQi27CE20yxQ@mail.gmail.com>
References: <1308708650-25509-1-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, joe@perches.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, linux-kernel@vger.kernel.org,
	Chetan Loke <loke.chetan@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308708650-25509-1-git-send-email-loke.chetan@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2011 at 10:10 PM, Chetan Loke <loke.chetan@gmail.com> w=
rote:
> Hello,
>
> Please review the patchset.
>
> Changes from v1:
>
> 1) v1 was based on 2.6.38.9. v2 is rebased to net-next.
> 2) Aligned bdqc members, pr_err to WARN, sob email =C2=A0 =C2=A0 =C2=A0=
(Joe Perches)
> 3) Added tp_padding =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (Eric Dumazet)
> 4) Nuked useless ;) white space =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (Stephen H)
> 5) Use __u types in headers =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (Ben Hutchings=
)
> 6) Added field for creating private area =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0(Chetan Loke)
>

Hi Dave,

Is there a chance of getting this merged either in 3.0 or 3.1 or ever ;=
) ?

thanks
Chetan
