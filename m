From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: RFC3465 Appropriate Byte Count fix
Date: Tue, 08 Aug 2006 22:47:28 -0700 (PDT)
Message-ID: <20060808.224728.74750395.davem@davemloft.net>
References: <010001c6bb71$097fd930$8b66130a@docomo.docomogr.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51387
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965075AbWHIFr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:47:27 -0400
To: osugad@s1.nttdocomo.co.jp
In-Reply-To: <010001c6bb71$097fd930$8b66130a@docomo.docomogr.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daikichi Osuga <osugad@s1.nttdocomo.co.jp>
Date: Wed, 09 Aug 2006 14:02:37 +0900

> In current RFC3465 Appropriate Byte Count implementation,
> slow start after retransmit timeout does not work.
> I fixed it.

Please provide diffs in unified format.

Also, your email client has corrupted the patch, changing tabs into
spaces.  This makes your patch unusable.

If you are in doubt, email the patch to yourself and try to apply it
from the email you receive.

Finally, provide a proper "Signed-off-by:" line with your changelog
description.

For more information please read Documentation/SubmittingPatches
in the kernel source tree.

Thank you.
