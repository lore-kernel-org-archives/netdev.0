From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] r8169: balance pci_map / pci_unmap pair
Date: Fri, 22 Aug 2008 00:18:16 +0200
Message-ID: <20080821221816.GA30366@electric-eye.fr.zoreil.com>
References: <20080821214734.GB22540@electric-eye.fr.zoreil.com> <20080821145711.86bace2a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	alistair@devzero.co.uk, tjfontaine@atxconsulting.com,
	edward_hsu@realtek.com.tw, ivecera@redhat.com, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51311 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755484AbYHUWTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:19:51 -0400
Content-Disposition: inline
In-Reply-To: <20080821145711.86bace2a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> :
[...]
> Also needed in 2.6.25.x and 2.6.26.x, yes?

Yes. Needed since 2.6.23.

-- 
Ueimor
