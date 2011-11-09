From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] staging: octeon-ethernet: Fix compile error caused by
 changed to struct skb_frag_struct.
Date: Wed, 9 Nov 2011 17:17:14 +0000
Message-ID: <20111109171714.GA31771@linux-mips.org>
References: <1320698970-1854-1-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org, gregkh@suse.de,
	devel@driverdev.osuosl.org, ddaney.cavm@gmail.com
To: David Daney <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:40420 "EHLO linux-mips.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751294Ab1KIRRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 12:17:32 -0500
Content-Disposition: inline
In-Reply-To: <1320698970-1854-1-git-send-email-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 07, 2011 at 12:49:30PM -0800, David Daney wrote:

> Evidently the definition of struct skb_frag_struct has changed, so we
> need to change to match it.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---

As usual for this drive I've applied this to the MIPS tree and will
send it to Linus in a few days unless somebody objects.

Thanks,

  Ralf
