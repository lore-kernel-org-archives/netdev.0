From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Wed, 13 Oct 2010 12:36:26 +0200
Message-ID: <1286966186.3876.246.camel@edumazet-laptop>
References: <20101009095346.GA12951@hera.kernel.org>
	 <20101009132749.GA15074@solarflare.com>	<4CB0C56C.2000106@kernel.org>
	 <20101012.115138.112614145.davem@davemloft.net>
	 <4CB4C6E6.9090805@kernel.org> <1286917039.1117.101.camel@Joe-Laptop>
	 <4CB54C4F.5070205@kernel.org> <1286951637.2703.141.camel@edumazet-laptop>
	 <4CB589B2.50907@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61819 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab0JMKgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 06:36:32 -0400
Received: by wwj40 with SMTP id 40so6273545wwj.1
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 03:36:31 -0700 (PDT)
In-Reply-To: <4CB589B2.50907@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 octobre 2010 =C3=A0 14:28 +0400, Denis Kirjanov a =C3=A9=
crit :

> +		u64 tx_defered;
> +		u64 tx_defered_excessive;

Joe said correct english word is "deferred", not "defered"



