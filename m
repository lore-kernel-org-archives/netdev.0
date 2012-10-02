From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:363:64: sparse:
 incorrect type in argument 3 (different base types)
Date: Tue, 2 Oct 2012 11:46:22 +0300
Message-ID: <20121002084622.GS4587@mwanda>
References: <20120928163653.GC5171@localhost>
 <8A71B368A89016469F72CD08050AD3340C527934@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Vipul Pandya <vipul@chelsio.com>,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: Jay Hernandez <jay@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:20787 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754421Ab2JBIqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 04:46:39 -0400
Content-Disposition: inline
In-Reply-To: <8A71B368A89016469F72CD08050AD3340C527934@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 01, 2012 at 05:48:55PM -0700, Jay Hernandez wrote:
> Hi Fengguang,
> 
> Thanks for pointing this out we have a fix which addresses these issues.
> What's interesting is I did not see these warnings I tried to reproduce
> the errors on my setup. Is there a special flag we can use to reproduce
> the sparse warnings.
> 

Yup.

http://lwn.net/Articles/205624/

regards,
dan carpenter
