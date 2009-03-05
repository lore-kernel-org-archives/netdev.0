From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 0/3] Fix Network namespace shutdown take 2
Date: Thu, 05 Mar 2009 13:35:58 +0100
Message-ID: <49AFC72E.60907@free.fr>
References: <m1ocwxi00a.fsf@fess.ebiederm.org>	<49A53CF1.5060503@free.fr> <20090303.010733.237605434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org, adobriyan@gmail.com, den@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:62152 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbZCEMgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 07:36:04 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.14.3/8.13.8) with ESMTP id n25Ca1Pt632056
	for <netdev@vger.kernel.org>; Thu, 5 Mar 2009 12:36:01 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n25Ca18l966868
	for <netdev@vger.kernel.org>; Thu, 5 Mar 2009 13:36:01 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n25Ca101003054
	for <netdev@vger.kernel.org>; Thu, 5 Mar 2009 13:36:01 +0100
In-Reply-To: <20090303.010733.237605434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <daniel.lezcano@free.fr>
> Date: Wed, 25 Feb 2009 13:43:29 +0100
>
>   
>> I don't see these patches in the net-2.6 tree. Shouldn't they be in
>> net-2.6 too ?
>>     
>
> Ok, I'll think about cherry picking them into net-2.6...
>   
Thanks Dave.
