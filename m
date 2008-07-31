From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [patch 08/11] nsc-ircc: default to dongle type 9 on IBM hardware
Date: Thu, 31 Jul 2008 01:13:26 +0100
Message-ID: <20080731001326.GA16246@srcf.ucam.org>
References: <200807301937.m6UJbfsn012452@imap1.linux-foundation.org> <20080730.170057.47288436.davem@davemloft.net> <20080730170720.041577ed.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ben.collins@canonical.com, samuel@sortiz.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:35569 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762832AbYGaANd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 20:13:33 -0400
Content-Disposition: inline
In-Reply-To: <20080730170720.041577ed.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2008 at 05:07:20PM -0700, Andrew Morton wrote:

> I have a feeling that 2.6.25.x and 2.6.26.x will want this one too.  I
> found it hard to judge how important this fix actually is.  But
> thinkpads are pretty common!

It's never automatically worked on Thinkpads, so I'm not too worried. 
Anyone who's tried using this has either given up (and so won't notice 
it's started working in a stable update) or already passes the dongle 
argument manually.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
