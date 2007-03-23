From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: VIA Velocity VLAN vexation
Date: Fri, 23 Mar 2007 22:43:26 +0100
Message-ID: <20070323214326.GA25478@electric-eye.fr.zoreil.com>
References: <20070322231626.GA23070@electric-eye.fr.zoreil.com> <20070323185102.16160.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54260 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992573AbXCWVoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 17:44:07 -0400
Content-Disposition: inline
In-Reply-To: <20070323185102.16160.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux@horizon.com <linux@horizon.com> :
[...]
> But I don't see any suggestions for an alternative gigabit
> card anywhere.  I had assumed they all mostly worked, but
> now it appears I need to know details.

Mostly.

Assuming you won't play with huge jumbo frames, I'd suggest
a plain old pci 8169 (not a PCIe 8168) for VLAN. 

[...]
> Haven't they been merged upstream already?

No.

-- 
Ueimor
