From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cxgb3: Update FW to 7.4.0
Date: Wed, 03 Jun 2009 17:54:30 -0700 (PDT)
Message-ID: <20090603.175430.193109210.davem@davemloft.net>
References: <20090603161910.17960.28171.stgit@speedy5>
	<4A27099E.3070202@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753294AbZFDAya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 20:54:30 -0400
In-Reply-To: <4A27099E.3070202@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 03 Jun 2009 16:39:10 -0700

> Please drop this patch. The FW image is corrupted.
> I reposted the patch with the correct image.

Will do.

Could you please address Ben's request that you use request_firmware()
for that in-source firmware blob you added for new PHY support
recently?  I never saw you even reply to his posting stating how you
intend to deal with that problem, and that's not acceptable. :-)

