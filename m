From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: small RPS cache for fragments?
Date: Mon, 06 Jun 2011 19:15:13 +0200
Message-ID: <1307380513.3098.76.camel@edumazet-laptop>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <20110524.160123.2051949867829317339.davem@davemloft.net>
	 <1306273128.8149.1444.camel@tardy>
	 <20110604.132940.2214949964968775365.davem@davemloft.net>
	 <1307380132.8149.2718.camel@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:50933 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab1FFRPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 13:15:17 -0400
Received: by wwk4 with SMTP id 4so1694668wwk.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 10:15:16 -0700 (PDT)
In-Reply-To: <1307380132.8149.2718.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 10:08 -0700, Rick Jones a =C3=A9crit :

> Mode-rr bonding reorders TCP segments all the time.=20

Shouldnt TCP frames have DF bit set ?





