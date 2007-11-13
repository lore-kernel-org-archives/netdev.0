From: David Miller <davem@davemloft.net>
Subject: Re: Re : [PATCH][IPv6] Add ifindex field in ND user option messages
Date: Mon, 12 Nov 2007 17:13:33 -0800 (PST)
Message-ID: <20071112.171333.81974629.davem@davemloft.net>
References: <225828.70511.qm@web25704.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	rdenis@simphalempin.com
To: linkfanel@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50998
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755002AbXKMBNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 20:13:34 -0500
In-Reply-To: <225828.70511.qm@web25704.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ynard <linkfanel@yahoo.fr>
Date: Tue, 13 Nov 2007 01:08:26 +0000 (GMT)

> > Unfortunately you cannot change the layout of a structure
> > already exported to userspace, it is part of the ABI.
> 
> Well, I thought it would not be a problem, as it is not exactly
> released yet. We are also currently developping the
> corresponding RDNSS daemon and would be totally ready to
> handle this change :)

Was it an interface added to 2.6.24?
