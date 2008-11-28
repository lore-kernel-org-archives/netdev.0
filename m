From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Fri, 28 Nov 2008 20:50:18 +0100
Message-ID: <20081128195018.GA19538@electric-eye.fr.zoreil.com>
References: <492DD792.6080302@linux.intel.com> <20081128111827.79b12739@osprey.hogchain.net> <20081128093217.3888fb46@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jcliburn@gmail.com>, NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34821 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752659AbYK1Tuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 14:50:44 -0500
Content-Disposition: inline
In-Reply-To: <20081128093217.3888fb46@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven <arjan@linux.intel.com> :
[...]
> For me, sis900 and r8169 stand out; if you look at the data in the
> table above, both of these are an order of magnitude more frequent than
> the rest of the pack.

via-rhine + via_rhine = 438: it does not look too good either.

Is there an (ideally automated) way to retrieve more information ?

The r8169 driver handles three different chipsets and a plethora of
phys. The "XID" line printed by the driver could hint at some specific
PHY for instance.

-- 
Ueimor
