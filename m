From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] XFRM: RFC4303 compliant auditing
Date: Fri, 21 Dec 2007 06:02:41 -0800 (PST)
Message-ID: <20071221.060241.19624191.davem@davemloft.net>
References: <20071221.014310.155404661.davem@davemloft.net>
	<200712210827.24063.paul.moore@hp.com>
	<200712210851.22521.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	latten@austin.ibm.com
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751336AbXLUOCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:02:42 -0500
In-Reply-To: <200712210851.22521.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 21 Dec 2007 08:51:22 -0500

> Ah, looks like I may not be crazy after all!  It looks like the XFRM patches 
> from Masahide NAKAMURA were pulled into net-2.6.25 just before mine last 
> night which caused my patches to conflict ...

Sorry.  I had double checked and was going to rework your patches
by hand if that was the case, but for some reason I didn't see
his patches as being the culprit causing the rejects when I
checked things out.

I must have looked over the history correctly.
