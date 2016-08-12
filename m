From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] qed: Fix possible memory leak in
 qed_dcbnl_get_ieee_pfc()
Date: Fri, 12 Aug 2016 10:49:19 -0700 (PDT)
Message-ID: <20160812.104919.412008599153333225.davem@davemloft.net>
References: <1470958194-25496-1-git-send-email-weiyj.lk@gmail.com>
	<BN6PR11MB189049E2D7F71CA1B47CDE56901F0@BN6PR11MB1890.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	Dept-EngEverestLinuxL2@qlogic.com, netdev@vger.kernel.org
To: Sudarsana.Kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbcHLRtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 13:49:31 -0400
In-Reply-To: <BN6PR11MB189049E2D7F71CA1B47CDE56901F0@BN6PR11MB1890.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Date: Fri, 12 Aug 2016 05:00:40 +0000

> Thanks for the patch.
> 
> Acked-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

Please do not quote patches like this, and top-post your Ack.

Please instead use canonical quoting, with some kind of delimiter
in the first column of the quoted material.

Unless you have specific comments for specific parts of the change
itself, do not quote the patch, just quoting the commit message itself
is sufficient.

And finally, put your ACK and any other part of your response, after
the quoted material rather than before.

The way you have ACK'd this patch, patchwork will not see it and
instead thinks this is a fresh new patch posting.  So your ACK will
get possibly lost, and I will definitely have more work to do weeding
out this extraneous patch entry in patchwork.

Thank you.
