From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [Cbe-oss-dev] [PATCH] spidernet: don't use debug flag
Date: Wed, 11 Jul 2007 15:37:42 -0500
Message-ID: <20070711203742.GI5549@austin.ibm.com>
References: <20070709212617.GM4457@austin.ibm.com> <200707110758.l6B7w1Jc026926@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44575 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756876AbXGKUhr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 16:37:47 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6BKbkGt004324
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 16:37:46 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6BKbhXZ509610
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 16:37:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6BKbggD013914
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 16:37:43 -0400
Content-Disposition: inline
In-Reply-To: <200707110758.l6B7w1Jc026926@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 11, 2007 at 04:57:38PM +0900, Ishizaki Kou wrote:
[...]
> I need more investigation. Please drop the patch.

OK.

--linas

p.s. I tested ifdown/ifup, and didn't see any problems.
Does your bug happen immediately, or does it take many attempts 
to trigger it?


