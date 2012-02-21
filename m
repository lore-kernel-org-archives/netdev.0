From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V3 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 19:51:54 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F95B64@ORSMSX106.amr.corp.intel.com>
References: <20120220.005451.548532173290909435.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F950C8@ORSMSX106.amr.corp.intel.com>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F9537C@ORSMSX106.amr.corp.intel.com>
 <20120221.144926.1106286806287642272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12872 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753236Ab2BUTv4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 14:51:56 -0500
In-Reply-To: <20120221.144926.1106286806287642272.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 21, 2012 11:49 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC V3 PATCH] rtnetlink: Fix problem with buffer allocation
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Tue, 21 Feb 2012 17:46:27 +0000
> 
> > Having seen no other review comments on this RFC or the related
> > iproute2 RFC I'll go ahead and work with Jeff Kirsher to get these
> > patches pushed for application.
> 
> What do you mean by this?  Simply repost this patch with the fix I
> asked for, and do it ASAP.
> 
> These are not Intel device driver specific changes, there is absolutely
> no need to get Jeff involved at all.  It can only make things take more
> time and add more red tape to the process of getting this urgent fix
> propagated.
> 
> I've been extremely patient allowing you to take more than a week or
> two to code up this fix for something which causes very serious
> regressions for users, don't add any new things that will consume even
> more time.

OK, I'll post it ASAP.

- Greg
