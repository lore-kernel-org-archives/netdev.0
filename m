From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 19:36:08 +0200
Message-ID: <1272389768.2295.402.camel@edumazet-laptop>
References: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
	 <20100426.110432.104061817.davem@davemloft.net>
	 <4BD6E887.3000804@athenacr.com>
	 <20100427.095108.68126984.davem@davemloft.net>
	 <1272388439.2295.369.camel@edumazet-laptop>
	 <g2k65634d661004271031r2eb2000bxc30013009509c410@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57020 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299Ab0D0Rlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:41:46 -0400
Received: by bwz19 with SMTP id 19so1908bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 10:41:44 -0700 (PDT)
In-Reply-To: <g2k65634d661004271031r2eb2000bxc30013009509c410@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 10:31 -0700, Tom Herbert a =C3=A9crit :

> This is the problem that we are addressing with so_reuseport!

How standard applications are protected against a DDOS ?



