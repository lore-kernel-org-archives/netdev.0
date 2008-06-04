From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix skb vs fack_count out-of-sync condition
Date: Wed, 04 Jun 2008 12:08:07 -0700 (PDT)
Message-ID: <20080604.120807.263602912.davem@davemloft.net>
References: <Pine.LNX.4.64.0805121349400.1888@wrl-59.cs.helsinki.fi>
	<483E0848.6030307@andyfurniss.entadsl.com>
	<Pine.LNX.4.64.0806041330030.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lists@andyfurniss.entadsl.com, netdev@vger.kernel.org,
	int986@gmail.com, brian.vowell@gmail.com, robbat2@gentoo.org,
	rjw@sisk.pl, akpm@linux-foundation.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758326AbYFDTII convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 15:08:08 -0400
In-Reply-To: <Pine.LNX.4.64.0806041330030.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 4 Jun 2008 13:42:43 +0300 (EEST)

> [PATCH] tcp: fix skb vs fack_count out-of-sync condition

Applied and queued up for -stable, thanks!
