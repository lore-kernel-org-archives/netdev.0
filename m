From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ppp_generic - use idr technique instead of
 cardmaps
Date: Wed, 17 Dec 2008 00:32:44 -0800 (PST)
Message-ID: <20081217.003244.67002510.davem@davemloft.net>
References: <20081216192000.GF26390@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xemul@openvz.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751249AbYLQIcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 03:32:42 -0500
In-Reply-To: <20081216192000.GF26390@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Tue, 16 Dec 2008 22:20:00 +0300

> Here is an attempt to convert cardmaps into ird.
> I would really appreciate any feedback.
> 
> I've tested ird under qemu (by some hacks not real ppp connection)
> so real loadings could reveal problems with the patch - review
> carefully please. (i'm not subcribed for netdev list CC me).
> 
> Any comments are _quite_ welcome! Paul?

This looks good to me.

I'll apply this to net-next-2.6, thanks!

