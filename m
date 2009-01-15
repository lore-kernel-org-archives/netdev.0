From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: GFP_DMA skb should not escape from driver
Date: Thu, 15 Jan 2009 15:29:21 -0800 (PST)
Message-ID: <20090115.152921.39574560.davem@davemloft.net>
References: <496F690A.2090606@cosmosbay.com>
	<200901151914.11421.ionut.leonte@gmail.com>
	<496F7251.7030300@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ionut.leonte@gmail.com, pp@ee.oulu.fi, mihai.dontu@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37586
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760913AbZAOX3T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 18:29:19 -0500
In-Reply-To: <496F7251.7030300@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 15 Jan 2009 18:28:49 +0100

> Ionut Leonte a =E9crit :
> > Applied, seems to fix the problem.
>=20
> Thanks for your report and testing !

Patch applied, thanks everyone.
