From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Mon, 01 Aug 2011 11:15:45 +0200
Message-ID: <1312190145.2719.2.camel@edumazet-laptop>
References: <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E32C76B.5010700@hippy.csoma.elte.hu>
	 <1311952306.2843.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110729.081902.300678107767426313.davem@davemloft.net>
	 <1311954208.2843.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1312002053.2873.41.camel@edumazet-laptop>
	 <4E366A8F.201@hippy.csoma.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: synapse <synapse@hippy.csoma.elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53779 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab1HAJQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 05:16:03 -0400
Received: by wyg8 with SMTP id 8so1421584wyg.19
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 02:16:01 -0700 (PDT)
In-Reply-To: <4E366A8F.201@hippy.csoma.elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 ao=C3=BBt 2011 =C3=A0 10:57 +0200, synapse a =C3=A9crit :
> Hello
>=20
> Sorry, I wasn't home on the weekend. Exactly to which tree should I=20
> apply this?
> It doesn't apply cleanly to 3.0.0. Am I missing something?
>=20

Could you try latest linux tree ?

We first validate patches on current tree, then backport them if needed
to previous kernels.

Thanks


