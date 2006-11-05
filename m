From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/02 V3] net/ipv6: seperate sit driver to extra module
Date: Sun, 05 Nov 2006 15:47:17 -0800 (PST)
Message-ID: <20061105.154717.90121153.davem@davemloft.net>
References: <454E671B.2090302@trash.net>
	<20061105.152718.88476049.davem@davemloft.net>
	<454E75E6.7010500@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joro-lkml@zlug.org, jdi@l4x.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31166
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932750AbWKEXrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 18:47:09 -0500
To: kaber@trash.net
In-Reply-To: <454E75E6.7010500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 06 Nov 2006 00:38:14 +0100

> David Miller wrote:
> > Would you like me to apply this or is this a temp workaround
> > for folks?
> 
> Please apply it. I usually build things as module if possible,
> which in this case caused my tunnel to break. This will
> probably happen to others as well.

Ok, done.

Thanks.
