From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Wed, 28 May 2014 11:26:10 +0800
Message-ID: <20140528032610.GA14567@richard>
References: <20140528014848.GB5830@richard>
 <20140527.193737.22275611325169063.davem@davemloft.net>
 <20140528024650.GA8602@richard>
 <20140527.231803.1411461924645076157.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:47480 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbaE1D0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 23:26:18 -0400
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 28 May 2014 08:56:15 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id BB7ED1258053
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 08:55:24 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4S3Qkul393658
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 08:56:46 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4S3QBFf030549
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 08:56:12 +0530
Content-Disposition: inline
In-Reply-To: <20140527.231803.1411461924645076157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2014 at 11:18:03PM -0400, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Wed, 28 May 2014 10:46:50 +0800
>
>> Could I backport it one version by one version? Or need to send out for these
>> four versions at the same time?
>
>It's awkward for me to submit a fix for only one release, I submit a
>specific set of fixes to all relevant -stable branches at one time.

Ok, got it :-)

-- 
Richard Yang
Help you, Help me
