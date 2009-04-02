From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 0/9] Neterion: New driver: vxge: Resubmit #4
Date: Thu, 02 Apr 2009 00:50:49 -0700 (PDT)
Message-ID: <20090402.005049.47433080.davem@davemloft.net>
References: <1238194418.5516.363.camel@flash>
	<1238645626.18544.209.camel@flash>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57152
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751136AbZDBHvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 03:51:00 -0400
In-Reply-To: <1238645626.18544.209.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ramkrishna Vepa <ram.vepa@neterion.com>
Date: 01 Apr 2009 20:13:47 -0800

> This series of 9 patches are a resubmission of Neterion's "vxge"
> driver. We've fixed the problems observed on the sparc64, ppc64 and IA64 
> plaforms. The driver has undergone a short test cycle on these platforms
> as well as x86 and x86_64 systems.
> 
> A summary of changes from the last submission -
> 1. Fixed compilation warnings and errors on sparc64, IA64 and PPC64 - Reported
> by Dave Miller.
> 2. Fixed aligned memory access warnings due to compare_ether_addr on sparc64.
> 3. Fixed sparse warning on IA64 with CONFIG_VXGE_DEBUG_TRACE_ALL enabled.
> 4. General clean up in patches 4, 5, 6 and 7.

Applied, thanks Ramkrishna.
