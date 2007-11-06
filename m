From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 01/02] r8169: add PCI ID for the 8168 in the Abit
 Fatal1ty F-190HD motherboard
Date: Tue, 6 Nov 2007 15:20:46 -0800
Message-ID: <20071106152046.3f549c85@freepuppy.rosehill>
References: <20071106222213.GA22170@electric-eye.fr.zoreil.com>
	<20071106222354.GB22170@electric-eye.fr.zoreil.com>
	<20071106143729.2625f464@freepuppy.rosehill>
	<20071106231908.GB18076@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50799 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753330AbXKFXX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 18:23:26 -0500
In-Reply-To: <20071106231908.GB18076@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Nov 2007 00:19:08 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> :
> [...]
> > Really, vendor_id is 1 ?
> 
> Yes, the bug seems to be commonly set in hardware.
> 
> > How about a comment about which board this is.
> 
> B3w4r3 0f Th3 3v1l Fatal1ty M0b0 ?
> 
> Imho 'git log/blame' will provide enough information for this hack.
> 

0k F1ne

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
