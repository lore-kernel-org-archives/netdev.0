From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 3.14-stable] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Tue, 17 Jun 2014 11:08:49 +0800
Message-ID: <20140617030849.GA12893@richard>
References: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20140617024951.GB7886@richard>
 <20140616.200348.1292584099498677236.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, netdev@vger.kernel.org,
	bhelgaas@google.com, amirv@mellanox.com, jackm@dev.mellanox.co.il,
	ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:47478 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbaFQDJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 23:09:04 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 17 Jun 2014 13:08:56 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 570E93578048
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 13:08:52 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5H2qd3a29556832
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 12:52:40 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5H38odB005823
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 13:08:51 +1000
Content-Disposition: inline
In-Reply-To: <20140616.200348.1292584099498677236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 08:03:48PM -0700, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Tue, 17 Jun 2014 10:49:51 +0800
>
>> I saw the fix for the crash during reboot is merged in mainline, while I am
>> not sure how to check these backport is merged in the stable tree(not familiar
>> to check it in stable tree.)
>> 
>> Do you suggest me to include that fix and send these backport again? Or?
>
>I haven't gotten around to working with your backports, it's in my queue.

Oh, got it :-)

If any issue, please let me know.

-- 
Richard Yang
Help you, Help me
