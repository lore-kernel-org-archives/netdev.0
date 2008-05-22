From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [TCP]: Reorganize tcp_sock to fill 64-bit holes &
 improve locality
Date: Wed, 21 May 2008 17:41:51 -0700 (PDT)
Message-ID: <20080521.174151.71570058.davem@davemloft.net>
References: <Pine.LNX.4.64.0805211534170.16829@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0805211536390.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37928
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754022AbYEVAl4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 20:41:56 -0400
In-Reply-To: <Pine.LNX.4.64.0805211536390.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 21 May 2008 15:40:15 +0300 (EEST)

> I'm not sure if this is a right time for such reorganization but it w=
on't=20
> hurt to post it anyway.

I think this is something for net-next-2.6, and after Eric
takes a look at this I'll add it there.

Thanks.
