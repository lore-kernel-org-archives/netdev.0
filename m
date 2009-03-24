From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: cleanup rx/tx rate calculations
Date: Tue, 24 Mar 2009 16:40:57 -0700 (PDT)
Message-ID: <20090324.164057.66047165.davem@davemloft.net>
References: <bdc3ac9f0903230451o60d3392akb390c9f5dc9aab20@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755833AbZCXXlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 19:41:10 -0400
In-Reply-To: <bdc3ac9f0903230451o60d3392akb390c9f5dc9aab20@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@gmail.com>
Date: Mon, 23 Mar 2009 17:21:09 +0530

> Hi, Pls accept this patch to cleanup rx/tx rate calculations as follows:
> - check for jiffies wraparound
> - remove typecast of a denominator
> - do rate calculation only in workqueue context periodically
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Your email client corrupted the patch, breaking up long lines
with newlines.

I fixed it up, but I will not do so next time and instead I
will kick the patch back to you or simply ignore the submission.
So please get this fixed.

Thanks.
