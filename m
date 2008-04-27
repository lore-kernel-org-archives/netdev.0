From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH 1/1 2.6.25-rc9] bnx2x: Add EEH support in bnx2x
 driver - 10G pci-express adapter
Date: Sun, 27 Apr 2008 12:12:38 +0300
Message-ID: <1209287558.4928.18.camel@lb-tlvb-eliezer.il.broadcom.com>
References: <1208983414.7339.31.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org
To: "wendy xiong" <wendyx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3828 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbYD0JSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2008 05:18:44 -0400
In-Reply-To: <1208983414.7339.31.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wendy,

I will add this into the next version of the driver.
A few minor changes are needed, I will take care of them.

Thanks
Eliezer

On Wed, 2008-04-23 at 13:43 -0700, wendy xiong wrote:
> Hi
> 
> To enable EEH suuport for this 10G pci-express adapter, we added 3 EEH
> callback functions in the driver and also msi/pcie state needs to be
> saved and restored for the adapter.
> 
> Thanks,
> Wendy
> 
> Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>



