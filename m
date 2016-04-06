From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: intel: remove dead links
Date: Wed, 06 Apr 2016 16:54:51 -0400 (EDT)
Message-ID: <20160406.165451.42694079252458681.davem@davemloft.net>
References: <3c9f8ea384ba033f83ec360eef17732ff0a5a8dd.1459866280.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbcDFUyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:54:54 -0400
In-Reply-To: <3c9f8ea384ba033f83ec360eef17732ff0a5a8dd.1459866280.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue,  5 Apr 2016 16:25:07 +0200

> The Kconfig for Intel NICs references two different URLs for the "Adapter
> & Driver ID Guide". Neither of those two links works. The current URL seems
> to be
> http://www.intel.com/content/www/us/en/support/network-and-i-o/ethernet-products/000005584.html
> but given it's apparently constantly changing, there's no point in having it
> in the help text.
> 
> Just keep a generic pointer to http://support.intel.com. Hopefully, this one
> will have a longer live. It still works, at least.
> 
> Futhermore, remove a link to "the latest Intel PRO/100 network driver for
> Linux", this has no place in the mainline kernel and the latest Linux driver
> it offers is from 2006, anyway.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

I expect Jeff to pull this into his tree, thanks.
