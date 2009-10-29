From: David Miller <davem@davemloft.net>
Subject: Re: [Pv-drivers] [PATCH] vmxnet3: remove duplicate #include
Date: Thu, 29 Oct 2009 06:50:11 -0700 (PDT)
Message-ID: <20091029.065011.19666108.davem@davemloft.net>
References: <20091028.222901.187567993.davem@davemloft.net>
	<20091028.225217.78322944.davem@davemloft.net>
	<8B1F619C9F5F454E81D90D3C161698D7017DFAA30F@EXCH-MBX-3.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, weiyi.huang@gmail.com
To: bhavesh@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752773AbZJ2Ntr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 09:49:47 -0400
In-Reply-To: <8B1F619C9F5F454E81D90D3C161698D7017DFAA30F@EXCH-MBX-3.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhavesh Davda <bhavesh@vmware.com>
Date: Thu, 29 Oct 2009 06:35:35 -0700

> In other words, don't just trivially remove the X86 Kconfig
> requirement for this driver.

Then I assume you're going to add the endianness handling
and send me a patch soon?
