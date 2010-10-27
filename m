From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG net-2.6 vlan/bonding] lockdep splats
Date: Wed, 27 Oct 2010 15:00:16 +0200
Message-ID: <1288184416.2709.109.camel@edumazet-laptop>
References: <1288175070.2709.86.camel@edumazet-laptop>
	 <20101027120334.GA11247@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39432 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761193Ab0J0NAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 09:00:20 -0400
Received: by mail-wy0-f174.google.com with SMTP id 28so674739wyf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 06:00:19 -0700 (PDT)
In-Reply-To: <20101027120334.GA11247@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 octobre 2010 =C3=A0 12:03 +0000, Jarek Poplawski a =C3=A9=
crit :

> Seems to be even older. Could you try this patch?

Indeed this is the right fix, I wonder why I did not catch it before ?

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



