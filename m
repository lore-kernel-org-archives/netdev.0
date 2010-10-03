From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Fix the condition passed to sk_wait_event()
Date: Sun, 03 Oct 2010 06:53:33 +0200
Message-ID: <1286081613.2582.3235.camel@edumazet-laptop>
References: <20101002.132659.71124680.davem@davemloft.net>
	 <970819.25375.qm@web53706.mail.re2.yahoo.com>
	 <20101002.170654.193719563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tomer_iisc@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34139 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab0JCExm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 00:53:42 -0400
In-Reply-To: <20101002.170654.193719563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 02 octobre 2010 =C3=A0 17:06 -0700, David Miller a =C3=A9crit=
 :
> From: Nagendra Tomar <tomer_iisc@yahoo.com>
> Date: Sat, 2 Oct 2010 16:54:23 -0700 (PDT)
>=20
> >      I had done the exercise of sending the patch to myself and
> >      applying it (copy-pasting just the patch). One thing that I se=
e
> >      is the long line in the description. If you are referring to
> >      that, I've fixed it and submitted it again. If not this, I'm a=
t
> >      loss.
>=20
> This new submission looks good, thank you.

Yes, but the email address in the "Signed-odd-by: ...." is mangled :(


