From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Thu, 05 May 2011 08:50:57 +0200
Message-ID: <1304578257.32152.782.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
	 <1303279470.2756.17.camel@edumazet-laptop>
	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
	 <1303286998.3186.18.camel@edumazet-laptop>
	 <1303290464.3186.32.camel@edumazet-laptop>
	 <1303293765.3186.74.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200904440.8634@router.home>
	 <1303309591.3186.84.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
	 <1304576296.32152.713.camel@edumazet-laptop>
	 <4DC24239.7050806@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65422 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab1EEGvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 02:51:03 -0400
Received: by mail-ww0-f44.google.com with SMTP id 36so2013194wwa.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 23:51:02 -0700 (PDT)
In-Reply-To: <4DC24239.7050806@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 mai 2011 =C3=A0 09:22 +0300, Pekka Enberg a =C3=A9crit :

> Oh, sorry, it got lost in my inbox. I can take care of it.
>=20

Thanks Pekka !


