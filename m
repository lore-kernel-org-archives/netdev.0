From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] lro: Generic Large Receive Offload for TCP traffic
Date: Wed, 08 Aug 2007 23:11:44 -0700 (PDT)
Message-ID: <20070808.231144.22645124.davem@davemloft.net>
References: <200708031441.14780.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, gallatin@myri.com,
	jeff@garzik.org, stefan.roscher@de.ibm.com, netdev@vger.kernel.org
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754917AbXHIGLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 02:11:50 -0400
In-Reply-To: <200708031441.14780.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Fri, 3 Aug 2007 14:41:14 +0200

> I think this patch could be the final version for now. It has been tested
> on two platforms (power and x86_64) and works very well.

I checked in the LRO patch and the two sample driver ports
to net-2.6.24, thanks!
