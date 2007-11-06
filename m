From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 01/02] r8169: add PCI ID for the 8168 in the Abit
	Fatal1ty F-190HD motherboard
Date: Wed, 7 Nov 2007 00:19:08 +0100
Message-ID: <20071106231908.GB18076@electric-eye.fr.zoreil.com>
References: <20071106222213.GA22170@electric-eye.fr.zoreil.com> <20071106222354.GB22170@electric-eye.fr.zoreil.com> <20071106143729.2625f464@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50524 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753320AbXKFXWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 18:22:42 -0500
Content-Disposition: inline
In-Reply-To: <20071106143729.2625f464@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> :
[...]
> Really, vendor_id is 1 ?

Yes, the bug seems to be commonly set in hardware.

> How about a comment about which board this is.

B3w4r3 0f Th3 3v1l Fatal1ty M0b0 ?

Imho 'git log/blame' will provide enough information for this hack.

-- 
Ueimor
