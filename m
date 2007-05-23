From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/8] Use menuconfig objects: SCTP
Date: Wed, 23 May 2007 14:49:07 -0700 (PDT)
Message-ID: <20070523.144907.89039959.davem@davemloft.net>
References: <200705232135.l4NLZsK9000661@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jengelh@linux01.gwdg.de, jengelh@gmx.de,
	sri@us.ibm.com, vladislav.yasevich@hp.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60795
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755407AbXEWVtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:49:05 -0400
In-Reply-To: <200705232135.l4NLZsK9000661@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Wed, 23 May 2007 14:35:54 -0700

> From: Jan Engelhardt <jengelh@linux01.gwdg.de>
> 
> Use menuconfigs instead of menus, so the whole menu can be disabled at once
> instead of going through all options.
> 
> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
> Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
