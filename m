From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: remove duplicated #include
Date: Wed, 28 Oct 2009 04:13:31 -0700 (PDT)
Message-ID: <20091028.041331.153815661.davem@davemloft.net>
References: <alpine.LRH.2.00.0910221631580.23769@sbhatewara-dev1.eng.vmware.com>
	<alpine.LRH.2.00.0910221634130.23769@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiyi.huang@gmail.com,
	pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37396
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751606AbZJ1LNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 07:13:07 -0400
In-Reply-To: <alpine.LRH.2.00.0910221634130.23769@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Thu, 22 Oct 2009 16:58:33 -0700 (PDT)

> 
> 
> Remove duplicate headerfile includes from vmxnet3_int.h
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> Signed-off-by: Bhavesh Davda <davda@vmware.com>

This patch doesn't apply to net-next-2.6, please resend.
