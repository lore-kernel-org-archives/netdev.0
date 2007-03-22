From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netem performance improvements
Date: Thu, 22 Mar 2007 12:19:03 -0700 (PDT)
Message-ID: <20070322.121903.59666831.davem@davemloft.net>
References: <20070321174231.890361963@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57423
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933075AbXCVTTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:19:04 -0400
In-Reply-To: <20070321174231.890361963@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 21 Mar 2007 10:42:31 -0700

> The following patches for the 2.6.22 net tree, increase the
> performance of netem by about 2x.  With 2.6.20 getting about
> 100K (out of possible 300K) packets per second, after these
> patches now at over 200K pps.

All patches applied to net-2.6.22, thanks Stephen.
