From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Remove lost_retrans zero special cases
Date: Thu, 18 Oct 2007 05:08:13 -0700 (PDT)
Message-ID: <20071018.050813.18578617.davem@davemloft.net>
References: <Pine.LNX.4.64.0710181314130.3767@kivilampi-30.cs.helsinki.fi>
	<20071018.195558.103454352.takano@axe-inc.co.jp>
	<Pine.LNX.4.64.0710181357370.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: takano@axe-inc.co.jp, y-kodama@aist.go.jp, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50779
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750731AbXJRMH7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 08:07:59 -0400
In-Reply-To: <Pine.LNX.4.64.0710181357370.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 18 Oct 2007 14:07:42 +0300 (EEST)

> Dave, please put this one to net-2.6 and forget the other patch with
> title "[TCP]: Add highest_sack_end_seq check back...", it would just
> add another (wrong) zero special case back (they won't conflict with
> each other, so being this verbose here) :-).

Done, thanks everyone.
