From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: rtnetlink and many VFs
Date: Fri, 22 Apr 2011 15:49:56 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755014603C6EA@orsmsx508.amr.corp.intel.com>
References: <43F901BD926A4E43B106BF17856F07550145FC75D6@orsmsx508.amr.corp.intel.com>
	<1303409517.3165.39.camel@bwh-desktop>
	<43F901BD926A4E43B106BF17856F0755014603C6BE@orsmsx508.amr.corp.intel.com>
 <20110422.153145.183062300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7475 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753659Ab1DVWt6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 18:49:58 -0400
In-Reply-To: <20110422.153145.183062300.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, April 22, 2011 3:32 PM
> To: Rose, Gregory V
> Cc: bhutchings@solarflare.com; netdev@vger.kernel.org; linux-net-
> drivers@solarflare.com
> Subject: Re: rtnetlink and many VFs
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Fri, 22 Apr 2011 15:29:41 -0700
> 
> > If someone who knew (or knows) a bit more about netlink could point
> > out where this limitation is set in the code I'd really appreciate
> > it.  I've been poking around for a few hours and still can't find
> > it.
> 
> NLMSG_GOODSIZE

Thank you sir!

- Greg

