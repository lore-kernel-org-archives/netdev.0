From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Sun, 19 Dec 2010 23:21:50 +0100
Message-ID: <4D0E857E.5060302@gmail.com>
References: <4D0DEDF9.7020102@itcare.pl> <1292773433.18869.153.camel@edumazet-laptop> <4D0E2E52.3090802@itcare.pl> <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com> <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36907 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757218Ab0LSWVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 17:21:55 -0500
Received: by wyb28 with SMTP id 28so2330479wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Dec 2010 14:21:54 -0800 (PST)
In-Reply-To: <4D0E8416.2030100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Pawe=C5=82 Staszewski wrote:

>> for sch_generic.h was ok.
>=20
> Should be enough to try after reverting this sch_generic.h change onl=
y.

Hmm... Sorry, I meant the change inside skb_act_clone(). I'll send a pa=
tch.
=20
Jarek P.
