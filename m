From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 21:30:55 +0200
Message-ID: <1272396655.2343.0.camel@edumazet-laptop>
References: <4BD5F553.6020006@hp.com>
	 <20100426.134051.232750473.davem@davemloft.net> <4BD5FC16.4070402@hp.com>
	 <20100426.135305.15235166.davem@davemloft.net> <4BD601C3.5030108@hp.com>
	 <1272393060.30392.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:60656 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab0D0TbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:31:00 -0400
Received: by bwz19 with SMTP id 19so16194bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 12:30:58 -0700 (PDT)
In-Reply-To: <1272393060.30392.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 21:31 +0300, Eilon Greenstein a =C3=A9cri=
t :

> Though the thread is going in a different direction now, I just wante=
d
> to clarify two things:
> - yes, the 57710 and 57711 only handle the IP (src+dst) for UDP toepl=
itz
> hash. We all agree that it is much better to address the UDP ports as
> well, but I think Rick Jones explained the process very well - thank =
you
> Rick. Just to add one more (lame) excuse: the HW was designed before =
new
> NAPI was introduced and it complies with the requirements from Redmon=
d
> - the next generation (57712) which we already sample does (finally)
> support it. We are working on a patch series to enhance the bnx2x to
> support this device now.
>=20

Thanks Eilon !


