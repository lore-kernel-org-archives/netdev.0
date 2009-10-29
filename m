From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: remove duplicate #include
Date: Thu, 29 Oct 2009 10:06:26 -0700
Message-ID: <89E2752CFA8EC044846EB8499819134101745F2120@EXCH-MBX-4.vmware.com>
References: <20091028.222901.187567993.davem@davemloft.net>
	<20091028.225217.78322944.davem@davemloft.net>
	<8B1F619C9F5F454E81D90D3C161698D7017DFAA30F@EXCH-MBX-3.vmware.com>
 <20091029.065011.19666108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Bhavesh Davda <bhavesh@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:41269 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753111AbZJ2RGW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 13:06:22 -0400
In-Reply-To: <20091029.065011.19666108.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, October 29, 2009 6:50 AM
> To: Bhavesh Davda
> Cc: Shreyas Bhatewara; pv-drivers@vmware.com; netdev@vger.kernel.org;
> weiyi.huang@gmail.com
> Subject: Re: [Pv-drivers] [PATCH] vmxnet3: remove duplicate #include
> 
> From: Bhavesh Davda <bhavesh@vmware.com>
> Date: Thu, 29 Oct 2009 06:35:35 -0700
> 
> > In other words, don't just trivially remove the X86 Kconfig
> > requirement for this driver.
> 
> Then I assume you're going to add the endianness handling
> and send me a patch soon?

Yes, I will post a patch soon.

Thanks.
->Shreyas
