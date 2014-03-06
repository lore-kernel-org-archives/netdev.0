From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/13] i40e: use ether_addr_equal_64bits
Date: Thu, 06 Mar 2014 15:45:15 -0500 (EST)
Message-ID: <20140306.154515.1690277406415963400.davem@davemloft.net>
References: <1394080845.2214.1.camel@jtkirshe-mobl>
	<CAP-MU4Nf=T-BZDpHnBzq8xcPf7CG3v2oMSD3fitAKXp=fP4XPw@mail.gmail.com>
	<1394134409.2214.27.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, joe@perches.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, kavindya.s.deegala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbaCFUpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 15:45:18 -0500
In-Reply-To: <1394134409.2214.27.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 06 Mar 2014 11:33:29 -0800

> On Thu, 2014-03-06 at 10:10 -0800, Shannon Nelson wrote:
>> No, none of those uses are fast path.  I'd prefer we drop this patch.
>> sln
>> 
> 
> Ok based on Joe's and Shannon's responses, I will drop this patch from
> the series.
> 
> Dave- v2 of the series will be coming shortly.

Ok.
