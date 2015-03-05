From: David Miller <davem@davemloft.net>
Subject: Re: [Fwd: Re: [PATCH -next] net: i40e: fix build, depends on
 CONFIGFS_FS]
Date: Wed, 04 Mar 2015 23:58:48 -0500 (EST)
Message-ID: <20150304.235848.1415311271924658171.davem@davemloft.net>
References: <1425413366.2556.76.camel@jtkirshe-mobl>
	<C5551D9AAB213A418B7FD5E4A6F30A0789282B02@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	john.ronciak@intel.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbCEE6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:58:50 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0789282B02@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Thu, 5 Mar 2015 00:34:05 +0000

> Dell will be the only vendor selling systems with Ethernet NICs that
> support this feature.  Dell will be providing documentation to their
> users about how to use configfs for configuration of this feature.
> Dell will be taking the customer calls that result from any issues
> that arise.

And if they use non-INTEL NICs that provide this feature, oh well we
duplicate this bastardized configfs turd into those driver too, right?

Not acceptable.
