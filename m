From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Thu, 09 Feb 2012 14:17:58 -0500 (EST)
Message-ID: <20120209.141758.1178484830649281136.davem@davemloft.net>
References: <C5551D9AAB213A418B7FD5E4A6F30A0702F87530@ORSMSX106.amr.corp.intel.com>
	<20120209.140137.825194006300440230.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F8759A@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140Ab2BITSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 14:18:00 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F8759A@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Thu, 9 Feb 2012 19:06:02 +0000

> OK, that's a bit more clear to me then.  And that's the only reason
> I mentioned that the semantics to 'ip link show' would change.  But
> now I see what you mean by the rubbish comment.  By default ip link
> show will set all the feature bits and I'll add option code to
> iproute2 to allow the user to turn it off.
> 
> Does that make sense?

Yes, it does.
