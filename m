From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: AW: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s
 X520 NIC no longer work with allow_unsupported_sfp=1
Date: Mon, 8 Dec 2014 20:16:12 +0000
Message-ID: <87618083B2453E4A8714035B62D67992501ADC3B@FMSMSX105.amr.corp.intel.com>
References: <D76AF9B3DDF5FF49833AC0A1396549060314FBD8@s554.babiel.com>
  <87618083B2453E4A8714035B62D67992337B4938@FMSMSX102.amr.corp.intel.com>
  <D76AF9B3DDF5FF49833AC0A1396549060314FC0C@s554.babiel.com>
 <1361367596.7173.52.camel@jtkirshe-mobl>
 <loom.20141206T180736-199@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Martin Bosner <m.bosner@x-ion.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2529 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752481AbaLHUQR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 15:16:17 -0500
In-Reply-To: <loom.20141206T180736-199@post.gmane.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org] On Behalf Of Martin Bosner
>Sent: Saturday, December 06, 2014 9:08 AM
>To: netdev@vger.kernel.org
>Subject: Re: AW: ixgbe: Regression, unsupported SFP+ modules
>on 10Gbit/s X520 NIC no longer work with
>allow_unsupported_sfp=1
>
>Jeff Kirsher <jeffrey.t.kirsher <at> intel.com> writes:
>
>>
>> We are currently working on the resolution to your issue.
>I have also
>> added your patch to my queue of ixgbe patches.
>>
>> Cheers,
>> Jeff
>>
>
>Any news on this?

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/drivers/net/ethernet/intel/ixgbe?id=345be204dcbb2cc7580a63bc377a185125a6f822

Thanks,
Emil

>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe
>netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-
>info.html
