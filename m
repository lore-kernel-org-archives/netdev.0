From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [r8169] WARNING: at net/sched/sch_generic.c
Date: Wed, 31 Mar 2010 14:29:29 +0200
Message-ID: <1270038569.2103.24.camel@edumazet-laptop>
References: <20100331102142.GA3294@swordfish.minsk.epam.com>
	 <20100331111942.GB13963@hmsreliant.think-freely.org>
	 <20100331121426.GB3294@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:62368 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032Ab0CaM3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 08:29:34 -0400
In-Reply-To: <20100331121426.GB3294@swordfish.minsk.epam.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 31 mars 2010 =C3=A0 15:14 +0300, Sergey Senozhatsky a =C3=A9=
crit :


> PKT_SIZE=3D"pkt_size 2048"
>=20

If you use 1024 bytes pktgen messages, do you still have the problem ?


