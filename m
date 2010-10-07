From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] bonding: add Speed/Duplex information
 to /proc/net/bonding/bond
Date: Wed, 06 Oct 2010 18:44:03 -0700 (PDT)
Message-ID: <20101006.184403.15225022.davem@davemloft.net>
References: <4ca4b878.KGc4gLtXHLSFlAdV%ole@ans.pl>
	<20101006.142424.246555203.davem@davemloft.net>
	<4CACEADA.70009@ans.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757279Ab0JGBnl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 21:43:41 -0400
In-Reply-To: <4CACEADA.70009@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ol=EAdzki <ole@ans.pl>
Date: Wed, 06 Oct 2010 23:32:10 +0200

> Please note however that this procfs file was recently changed ("Slav=
e
> queue ID" was added) so if this is indeed a problem than we would
> already heard about this.

You make a good argument, therefore I have decided to apply
your patch.

Thanks.

