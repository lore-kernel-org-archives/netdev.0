From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 00/10] bna: Update Brocade BNA Ethernet driver to
 v2.3.2.3
Date: Sat, 25 Dec 2010 19:24:09 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A5CFD83830@HQ1-EXCH01.corp.brocade.com>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
 <20101225.191813.193696521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38364 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751645Ab0LZDYS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 22:24:18 -0500
In-Reply-To: <20101225.191813.193696521.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David!

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Saturday, December 25, 2010 7:18 PM
>To: Rasesh Mody
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH 00/10] bna: Update Brocade BNA Ethernet driver to
>v2.3.2.3
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Tue, 21 Dec 2010 23:23:06 -0800
>
>> The following patch set updates the Brocade BNA driver to v2.3.2.3.
>>
>> The patches are generated, compiled and tested against net-next-2.6
>(2.6.37-rc1).
>>
>> Rasesh Mody (10):
>>   bna: TxRx and datapath fix
>>   bna: Port enable disable sync and txq priority fix
>>   bna: Fix ethtool register dump and reordered an API
>>   bna: Enable pure priority tagged packet reception and rxf uninit
>>     cleanup fix
>>   bna: Fix for TX queue
>>   bna: IOC uninit check and misc cleanup
>>   bna: Removed unused code
>>   bna: Restore VLAN filter table
>>   bna: IOC failure auto recovery fix
>>   bna: Update the driver version to 2.3.2.3
>
>All applied, thanks.
