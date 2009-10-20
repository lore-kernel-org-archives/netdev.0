From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: build test your changes!
Date: Tue, 20 Oct 2009 09:36:30 +0200
Message-ID: <4ADD687E.4040808@gmail.com>
References: <20091019.232204.52827242.davem@davemloft.net> <OF1BCE4CF8.BD48A587-ON65257655.0024B1CD-65257655.0025CC6C@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58809 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbZJTHgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 03:36:32 -0400
In-Reply-To: <OF1BCE4CF8.BD48A587-ON65257655.0024B1CD-65257655.0025CC6C@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar2 a =E9crit :

> Sorry about the build failure. I did do a build and a stress test. Bu=
t
> I missed changing the name sk_record_tx_queue() in both sock.h
> and dev.c when testing. I caught the miss before sending the patch,
> but changed the name only in sock.h, and didn't do a final build
> again. Sorry about this, will not assume next time.
>=20
> I will fix this (including patch order) and resend after build and te=
st.
>=20

Yes please, I am looking for your patches being added before my next ro=
und :)

(Specifically, I was waiting sizeof(struct sock_common) goes from 0x38 =
to 0x40=20
on 64 bit arches)
