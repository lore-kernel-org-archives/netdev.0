From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: net-2.6.25 is no more...
Date: Wed, 30 Jan 2008 10:03:09 +0100
Message-ID: <47A03D4D.5090301@fr.ibm.com>
References: <20080129.212216.186173371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:24277 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417AbYA3JHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 04:07:40 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0U97cxH317160
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 09:07:38 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U97c9R4407502
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 09:07:38 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U97Yq6017199
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 09:07:34 GMT
In-Reply-To: <20080129.212216.186173371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Now that the bulk has been merged over and we are
> actively working alongside Linus's tree I have moved
> all current patch applying to net-2.6 instead of net-2.6.25,
> so the current tree to use is:
> 
> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

This tree is for fixes only, right ? or shall we send enhancement 
patches to net-2.6 until net-2.6.26 appears ?
