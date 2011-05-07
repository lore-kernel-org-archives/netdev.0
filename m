From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hamachi: Delete TX checksumming code commented out
 since 1999
Date: Sat, 07 May 2011 01:02:29 -0700 (PDT)
Message-ID: <20110507.010229.71120168.davem@davemloft.net>
References: <20110506.115945.104066424.davem@davemloft.net>
	<BANLkTi=ZeY6X1XOdK2UXsODNBqzbbG+4KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752013Ab1EGIDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 04:03:01 -0400
In-Reply-To: <BANLkTi=ZeY6X1XOdK2UXsODNBqzbbG+4KQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
Date: Sat, 7 May 2011 09:59:28 +0200

> This also disables RX checksumming. You wanted to leave '#define
> RX_CHECKSUM' in place?

Oops, I'll fix that, thanks.
