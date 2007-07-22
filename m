From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/1] lro: Generic Large Receive Offload for TCP traffic
Date: Sat, 21 Jul 2007 19:29:04 -0700 (PDT)
Message-ID: <20070721.192904.10298367.davem@davemloft.net>
References: <200707201741.49290.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com,
	johnpol@2ka.mipt.ru
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52574
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750909AbXGVC3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 22:29:05 -0400
In-Reply-To: <200707201741.49290.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Fri, 20 Jul 2007 17:41:48 +0200

> Generic LRO patch
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

I have no general objections to this patch.

However I'd like to see at least one or two uses of these APIs before
we put it in, and it sounds as if we have at least two pending and
in the works if not ready already, so that shouldn't be an issue.

Thanks.
