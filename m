From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: Added support for RR qdisc (sch_rr)
Date: Thu, 21 Jun 2007 18:50:07 -0700
Message-ID: <20070621185007.493c0043@oldman>
References: <20070621212658.31100.74012.stgit@localhost.localdomain>
	<20070621212704.31100.29812.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57669 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751461AbXFVBur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 21:50:47 -0400
In-Reply-To: <20070621212704.31100.29812.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Jun 2007 14:27:04 -0700
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> wrote:

> Add tc support for the sch_rr qdisc.  This qdisc supports multiple queues
>     on hardware.  The syntax for sch_rr is the same as sch_prio.
> 
>     Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 

If the rr discipline makes it into mainline, I'll add it to iproute2.
If RR stays out of tree, then you need maintain it yourself
