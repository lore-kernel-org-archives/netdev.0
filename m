From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] netxen : fix BOND_MODE_TLB/ALB mode.
Date: Sat, 21 Nov 2009 11:36:53 -0800 (PST)
Message-ID: <20091121.113653.174520651.davem@davemloft.net>
References: <1258790937-19100-1-git-send-email-amit@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	narender.kumar@qlogic.com, amit.salecha@qlogic.com
To: amit@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753373AbZKUTgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 14:36:36 -0500
In-Reply-To: <1258790937-19100-1-git-send-email-amit@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@netxen.com>
Date: Sat, 21 Nov 2009 00:08:57 -0800

> As netxen driver need to set mac addr when ever interface comes up,
> it can't rely on netdev->dev_addr field. Specially in case of
> bonding mode ALB/TLB.

Thanks a lot, now I understand your patch better.

I'll all 3 patches to net-2.6, thanks again.
