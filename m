From: =?utf-8?B?RnJhbsOnb2lz?= Romieu <romieu@fr.zoreil.com>
Subject: Re: Bonding/LACP on RTL8169sc/8110sc (R1869)
Date: Wed, 13 Apr 2011 19:49:43 +0200
Message-ID: <20110413174943.GD17579@electric-eye.fr.zoreil.com>
References: <4DA45518.60407@navigue.com> <13118.1302648465@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonathan Thibault <jonathan@navigue.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57185 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043Ab1DMR5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 13:57:45 -0400
Content-Disposition: inline
In-Reply-To: <13118.1302648465@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 12, 2011 at 03:47:45PM -0700, Jay Vosburgh wrote:
> Jonathan Thibault <jonathan@navigue.com> wrote:
[2.6.32.old]
> 	That's a fairly old kernel; one relatively recent fix that comes
> to mind is:

The r8169 driver has undergone some multicast fixes since 2.6.32 as well.

If I remember correctly, the old 8169 - not the 8168 - was hit.

Upgrading is really suggested.

-- 
Ueimor
