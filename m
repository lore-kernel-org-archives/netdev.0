From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] flow: better memory management
Date: Mon, 13 Sep 2010 11:52:03 +0200
Message-ID: <1284371524.2587.214.camel@edumazet-laptop>
References: <1284138025.24675.100.camel@edumazet-laptop>
	 <87tyluk35t.fsf@basil.nowhere.org>
	 <1284357111.5560.2533.camel@edumazet-laptop>
	 <20100913104344.308e9392@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46914 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab0IMJwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 05:52:08 -0400
Received: by fxm16 with SMTP id 16so2986447fxm.19
        for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 02:52:07 -0700 (PDT)
In-Reply-To: <20100913104344.308e9392@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 septembre 2010 =C3=A0 10:43 +0200, Andi Kleen a =C3=A9crit =
:
> >=20
> > At boot : Allocate tables for online cpus
> >=20
> > When bringing up a cpu online : allocate table for this "new" cpu.
>=20
> You're right, I misread the patch. I thought that part was missing.
>=20

Ah, OK, thanks for clarification !



