From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] ethtool.8: Add missing 1G and 10G link modes, and full
 names for all modes
Date: Mon, 27 Jan 2014 11:55:36 -0800
Message-ID: <20140127115536.00006bad@unknown>
References: <20131120022540.6464.98397.stgit@jbrandeb-snb.jf.intel.com>
	<1390785735.2735.96.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48113 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753618AbaA0Tzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 14:55:37 -0500
In-Reply-To: <1390785735.2735.96.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jan 2014 01:22:15 +0000
Ben Hutchings <ben@decadent.org.uk> wrote:

> The 1G and 10G backplane link modes were missing from the table for
> the 'advertise' keyword.  Most link modes had only speed and duplex
> listed; change them to be consistent with ethtool's own output.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> I applied this on top of your patch.

FWIW (I know you already committed it)

Reviewed-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

---

Thanks Ben!
