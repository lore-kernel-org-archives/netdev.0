From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: net-2.6.25 is no more...
Date: Wed, 30 Jan 2008 18:38:53 +0100
Message-ID: <47A0B62D.3080005@fr.ibm.com>
References: <20080129.212216.186173371.davem@davemloft.net> <47A03D4D.5090301@fr.ibm.com> <20080130.054807.182676684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:38360 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbYA3RnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 12:43:23 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0UHhMYC492318
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 17:43:22 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0UHhMap2044104
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 18:43:22 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0UHhMGN031732
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 18:43:22 +0100
In-Reply-To: <20080130.054807.182676684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> Date: Wed, 30 Jan 2008 10:03:09 +0100
> 
>> David Miller wrote:
>>> Now that the bulk has been merged over and we are
>>> actively working alongside Linus's tree I have moved
>>> all current patch applying to net-2.6 instead of net-2.6.25,
>>> so the current tree to use is:
>>>
>>> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
>> This tree is for fixes only, right ? or shall we send enhancement 
>> patches to net-2.6 until net-2.6.26 appears ?
> 
> The latter.

What will happen to the patches sent to net-2.6.25 a few days ago during 
the merge ? Should I resend them against net-2.6 ?
