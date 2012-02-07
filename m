From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH RESEND] FEC: Rename dev to ndev, fix compile error
Date: Tue, 7 Feb 2012 21:31:56 -0200
Message-ID: <CAOMZO5Dq4o9BWfsL97awSaxeqHrLZK5GYb+JS1cpghSeaEfYYw@mail.gmail.com>
References: <1328654643-28442-1-git-send-email-marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Pradeep A Dalvi <netdev@pradeepdalvi.com>,
	"David S. Miller" <davem@davemloft.net>
To: Marek Vasut <marek.vasut@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39548 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756603Ab2BGXb6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 18:31:58 -0500
Received: by eaah12 with SMTP id h12so2999184eaa.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 15:31:56 -0800 (PST)
In-Reply-To: <1328654643-28442-1-git-send-email-marek.vasut@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marek,

On Tue, Feb 7, 2012 at 8:44 PM, Marek Vasut <marek.vasut@gmail.com> wro=
te:
> The following commit introduced a typo, this commit fixes it.
>
> commit 21a4e46995fa1a76281ac0281ff837f706231a37
> Author: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> Date: =C2=A0 Sun Feb 5 02:50:10 2012 +0000
>
> =C2=A0 =C2=A0netdev: ethernet dev_alloc_skb to netdev_alloc_skb
>
> =C2=A0 =C2=A0Replaced deprecating dev_alloc_skb with netdev_alloc_skb=
 in drivers/net/ethernet
> =C2=A0 =C2=A0 =C2=A0- Removed extra skb->dev =3D dev after netdev_all=
oc_skb
>
> Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
> Cc: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> Cc: David S. Miller <davem@davemloft.net>

I have already sent a fix for this issue and David has applied it.

Regards,

=46abio Estevam
