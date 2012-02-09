From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Thu, 9 Feb 2012 18:45:59 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F874CA@ORSMSX106.amr.corp.intel.com>
References: <20120207223346.21320.89370.stgit@gitlad.jf.intel.com>
	<20120208.201018.97784090083485473.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F86E01@ORSMSX106.amr.corp.intel.com>
 <20120209.134347.615561064709168825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41312 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758190Ab2BISqY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 13:46:24 -0500
In-Reply-To: <20120209.134347.615561064709168825.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, February 09, 2012 10:44 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Thu, 9 Feb 2012 16:25:31 +0000
> 
> > That will change the semantics to the 'ip link show' command quite a
> bit.
> 
> I think that's rubbish.
> 
> You can make "ip link show" do whatever you want, including setting all
> feature bits in getlink requests, which will preserve existing behavior.

But there will be a change to the command line semantics no?  How do I communicate which feature bits to set in getlink requests otherwise?

- Greg
