From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP
 cookie option, extend existing struct's
Date: Tue, 17 Nov 2009 04:48:17 -0800 (PST)
Message-ID: <20091117.044817.129685938.davem@davemloft.net>
References: <alpine.DEB.2.00.0911171412380.7024@wel-95.cs.helsinki.fi>
	<20091117.042250.28821014.davem@davemloft.net>
	<alpine.DEB.2.00.0911171432420.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, william.allen.simpson@gmail.com,
	netdev@vger.kernel.org, joe@perches.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35947
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752531AbZKQMsB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 07:48:01 -0500
In-Reply-To: <alpine.DEB.2.00.0911171432420.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 17 Nov 2009 14:38:42 +0200 (EET)

> Right, but we could be just as crazy and just drop such things and
> keep resending SYN+DATA without any harm?

Two crazies =3D=3D sane? :-)

Sure, we could do that.
