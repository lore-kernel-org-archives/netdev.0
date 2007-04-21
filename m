From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp,
 ...) -> func(sk, ...)
Date: Fri, 20 Apr 2007 22:18:28 -0700 (PDT)
Message-ID: <20070420.221828.105172765.davem@davemloft.net>
References: <Pine.LNX.4.64.0704161758020.28337@kivilampi-30.cs.helsinki.fi>
	<462396F5.9030907@trash.net>
	<Pine.LNX.4.64.0704161913400.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, hch@infradead.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753729AbXDUFSZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Apr 2007 01:18:25 -0400
In-Reply-To: <Pine.LNX.4.64.0704161913400.28337@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 16 Apr 2007 19:19:02 +0300 (EEST)

> [PATCH] [TCP]: Sed magic converts func(sk, tp, ...) -> func(sk, ...)

I decided to apply this to my net-2.6.22 tree, I'll deal with
the tcp-2.6 merge conflicts as best as I can.
