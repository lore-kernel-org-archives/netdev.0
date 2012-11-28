From: Einar Lueck <elelueck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] tcp: introduce raw access to experimental options
Date: Wed, 28 Nov 2012 11:12:27 +0100
Message-ID: <50B5E38B.4020107@linux.vnet.ibm.com>
References: <1353084898-42264-1-git-send-email-elelueck@linux.vnet.ibm.com> <20121116.134424.1929556546744828875.davem@davemloft.net> <50ACE496.20705@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frankbla@de.ibm.com, raspl@de.ibm.com,
	ubacher@de.ibm.com, samudrala@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:53572 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507Ab2K1KMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 05:12:33 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <elelueck@linux.vnet.ibm.com>;
	Wed, 28 Nov 2012 10:12:32 -0000
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qASACLqC1835356
	for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 10:12:21 GMT
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAS9QFIA013268
	for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 04:26:15 -0500
In-Reply-To: <50ACE496.20705@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2012 03:26 PM, Einar Lueck wrote:
> On 11/16/2012 07:44 PM, David Miller wrote:
>>
>> Unprivileged access to set and fetch these things?  I don't think
>> that's a good idea.
>>
>> Also, your code has a lot of coding style errors.
>>
>
> Would a restriction to a CAP_NET_ADMIN like privilege level address and
> resolve your concerns?
>
> Thx,
> Einar.

Would CAP_NET_ADMIN address your concerns? If would go ahead then and 
work on a corresponding new version of the patch.

Thx,
Einar.
