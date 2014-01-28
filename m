From: David Miller <davem@davemloft.net>
Subject: Re: i40e: Add missing braces to i40e_dcb_need_reconfig()
Date: Mon, 27 Jan 2014 20:17:49 -0800 (PST)
Message-ID: <20140127.201749.2176003536308418384.davem@davemloft.net>
References: <20140128041109.GA25771@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neerav.Parikh@intel.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbaA1ERw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 23:17:52 -0500
In-Reply-To: <20140128041109.GA25771@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 27 Jan 2014 23:11:09 -0500

> Indentation mismatch spotted with Coverity.
> Introduced in 4e3b35b044ea ("i40e: add DCB and DCBNL support")
>  
> Signed-off-by: Dave Jones <davej@fedoraproject.org>

Looks straightforward enough for me to apply directly, thanks
Dave.
