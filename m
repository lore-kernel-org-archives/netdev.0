From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next 05/15] i40e: add a comment on barrier and fix panic
 on reset
Date: Thu, 9 Jan 2014 20:14:30 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A07848F403C@ORSMSX108.amr.corp.intel.com>
References: <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<52CEB538.50505@cogentembedded.com>	<20140109091735.00002cf0@unknown>
 <20140109.151224.1539252523028219271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62131 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756062AbaAIUOc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 15:14:32 -0500
In-Reply-To: <20140109.151224.1539252523028219271.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, January 09, 2014 12:12 PM
> To: Rose, Gregory V
> Cc: sergei.shtylyov@cogentembedded.com; Kirsher, Jeffrey T;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com; Williams,
> Mitch A; Brandeburg, Jesse
> Subject: Re: [net-next 05/15] i40e: add a comment on barrier and fix panic
> on reset
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Thu, 9 Jan 2014 09:17:35 -0800
> 
> > Yes, it's apparent that two different internal patches were compressed
> > together.  If its unacceptable to do this then I'll speak to Jeff
> > about splitting them.
> 
> I won't reject the entire pull request on account of this, but please
> don't do this in the future.

Thanks Dave,

We've discussed this internally and ahem... mistakes were made.  We'll look out for it in the future.

- Greg
