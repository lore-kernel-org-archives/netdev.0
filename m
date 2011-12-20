From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: macvtap rxhash patch
Date: Tue, 20 Dec 2011 08:51:05 +0530
Message-ID: <OF7DCC4D0D.E909B609-ON6525796C.0011F75F-6525796C.00122AAB@in.ibm.com>
References: <20111219.163732.1743893510814385117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: mst@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:56935 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935Ab1LTDSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 22:18:33 -0500
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Tue, 20 Dec 2011 08:48:30 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBK3IRen4005888
	for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 08:48:27 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBK3IQ70008867
	for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 14:18:26 +1100
In-Reply-To: <20111219.163732.1743893510814385117.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 12/20/2011 03:07:32 AM:

> Reference:
>
> http://patchwork.ozlabs.org/patch/127456/
>
> This is just rotting for a long time, I want to just do something
> with this patch, and I don't care if that's "apply it now" or
> "defer indefinitely".

Michael, what do you suggest? I expect this should work
as expected for all NIC's, though I have tested only
with ixgbe.

thanks,
- KK
