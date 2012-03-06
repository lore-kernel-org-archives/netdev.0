From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.3.0-rc5: OOps in dql_completed (Broadcom tg3 driver)
Date: Mon, 05 Mar 2012 21:22:28 -0800
Message-ID: <1331011348.2474.28.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1203011505510.6685@router.home>
	 <1330698646.2469.28.camel@edumazet-laptop>
	 <CA+mtBx_vNcPr-q7FSKXCAsVqvjZt=4UpWfv5eAp0=diG0wnbjQ@mail.gmail.com>
	 <CA+mtBx8oiDq+k3U705xYaV3xUsi=DnSWwCkymEONRcX3su77Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@gentwo.org>, mcarlson@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+mtBx8oiDq+k3U705xYaV3xUsi=DnSWwCkymEONRcX3su77Fg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 05 mars 2012 =C3=A0 21:14 -0800, Tom Herbert a =C3=A9crit :
> BQL implementation for tg3 does not handle multi queue correctly.
> Will have a fix for that momentarily.
>=20

Ah good catch.=20

I never had a multi queue tg3, I couldnt figure out this :)
