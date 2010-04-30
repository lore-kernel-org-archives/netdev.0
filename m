From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: enable/disable ASPM L0s and L1 and ERT
 according to hardware errata
Date: Fri, 30 Apr 2010 12:51:47 -0700 (PDT)
Message-ID: <20100430.125147.84367639.davem@davemloft.net>
References: <8DD2590731AB5D4C9DBF71A877482A9062274501@orsmsx509.amr.corp.intel.com>
	<20100429.120416.184828647.davem@davemloft.net>
	<8DD2590731AB5D4C9DBF71A877482A90622DE3C2@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, mjg@redhat.com
To: bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43278
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755630Ab0D3Tvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 15:51:41 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90622DE3C2@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Date: Fri, 30 Apr 2010 12:27:02 -0700

> In that case, I agree with Anton's patch.
> 
> Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>

Great, applied, thanks guys.
