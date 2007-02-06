From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Mon, 05 Feb 2007 17:43:26 -0800 (PST)
Message-ID: <20070205.174326.45743730.davem@davemloft.net>
References: <20070206.102405.86919923.yoshfuji@linux-ipv6.org>
	<20070205.173258.102576664.davem@davemloft.net>
	<20070206.104408.87339760.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56658
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933168AbXBFBn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 20:43:27 -0500
In-Reply-To: <20070206.104408.87339760.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 06 Feb 2007 10:44:08 +0900 (JST)

> Yes, I agree, but I think it is different issue, and
> maybe, we should check and change other places as well,
> in separate patch(es).

I agree.
