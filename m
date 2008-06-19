From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net/sched/sch_generic.c: fix an error pointer
Date: Thu, 19 Jun 2008 16:11:08 -0700 (PDT)
Message-ID: <20080619.161108.23678497.davem@davemloft.net>
References: <20080619153714.5614d5be@hack>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: wcong@critical-links.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753622AbYFSXLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:11:08 -0400
In-Reply-To: <20080619153714.5614d5be@hack>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WANG Cong <wcong@critical-links.com>
Date: Thu, 19 Jun 2008 15:37:14 +0100

> ERR_PTR() ususally encodes an negative errno, not positive.
> 
> Note, in the following patch, 'err' is initialized as:
> 
> int err = -ENOBUFS;
> 
> Signed-off-by: WANG Cong <wcong@critical-links.com>

Patch is whitespace corruped and line wrapped by your
email client.

Please fix this and resubmit, thank you.
