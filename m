From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [Fwd: Re: [PATCH -next] net: i40e: fix build, depends on
 CONFIGFS_FS]
Date: Thu, 5 Mar 2015 05:49:19 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0789282CB7@ORSMSX108.amr.corp.intel.com>
References: <1425413366.2556.76.camel@jtkirshe-mobl>
	<C5551D9AAB213A418B7FD5E4A6F30A0789282B02@ORSMSX108.amr.corp.intel.com>
 <20150304.235848.1415311271924658171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36301 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752067AbbCEFtY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 00:49:24 -0500
In-Reply-To: <20150304.235848.1415311271924658171.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, March 04, 2015 8:59 PM
> To: Rose, Gregory V
> Cc: Kirsher, Jeffrey T; netdev@vger.kernel.org; Brandeburg, Jesse; Nelson,
> Shannon; Ronciak, John
> Subject: Re: [Fwd: Re: [PATCH -next] net: i40e: fix build, depends on
> CONFIGFS_FS]
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Thu, 5 Mar 2015 00:34:05 +0000
> 
> > Dell will be the only vendor selling systems with Ethernet NICs that
> > support this feature.  Dell will be providing documentation to their
> > users about how to use configfs for configuration of this feature.
> > Dell will be taking the customer calls that result from any issues
> > that arise.
> 
> And if they use non-INTEL NICs that provide this feature, oh well we
> duplicate this bastardized configfs turd into those driver too, right?
> 
> Not acceptable.

I'll work with Jeff to remove the offending code.

- Greg
