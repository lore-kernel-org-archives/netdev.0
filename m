From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] correct typo in __xfrm4_bundle_create()
Date: Wed, 05 Dec 2007 05:20:34 -0800 (PST)
Message-ID: <20071205.052034.251196808.davem@davemloft.net>
References: <d0383f90712050249q3bc0e249h4cb66dc0ea97f172@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ianbrn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60616
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750896AbXLENUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 08:20:35 -0500
In-Reply-To: <d0383f90712050249q3bc0e249h4cb66dc0ea97f172@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ian Brown" <ianbrn@gmail.com>
Date: Wed, 5 Dec 2007 12:49:52 +0200

>  This is a typo correction in net/ipv4/xfrm4_policy.c; it should be
> "Copy neighbour" instead "Copy neighbout",

Your email client has corrupted the patch by adding
newlines among other things.

This happens often for gmail users, because by default
gmail does text formatting which you don't want it
to do for patches because it corrupts them.

Please use an attachment or some other method to prevent
this form happening so that you patch is not corrupted.
