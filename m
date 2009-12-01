From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/10] Remove skb_dma_map/unmap calls
Date: Mon, 30 Nov 2009 20:16:25 -0800 (PST)
Message-ID: <20091130.201625.193689129.davem@davemloft.net>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
	<20091129.234037.232627669.davem@davemloft.net>
	<80769D7B14936844A23C0C43D9FBCF0F12C7400AD3@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753244AbZLAEQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 23:16:20 -0500
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F12C7400AD3@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Mon, 30 Nov 2009 17:03:25 -0800

> David Miller wrote:
>> These changes look good, but at least one of them does not apply
>> to current net-2.6
>> 
>> Can you respin this against current sources?
>> 
>> Thanks a lot for doing this work Alexander.
>
> Due to the fact that nobody else had reported the issue and it
> existed in previous kernel versions I figured it would be easier to
> just drop it into net-next-2.6.
>
> If you want I can change the patches to net-2.6 though if that is
> what you would prefer.

Ok, net-next-2.6 is fine with me too.
