From: Joy Latten <latten@austin.ibm.com>
Subject: Re: IPSec kernel oops on ppc64
Date: Tue, 29 Aug 2006 17:16:54 -0500
Message-ID: <200608292216.k7TMGsXI029433@faith.austin.ibm.com>
Cc: gcwilson@us.ibm.com, herbert@gondor.apana.org.au,
	jmorris@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36535 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751202AbWH2W16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 18:27:58 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TMRv6i000928
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 18:27:57 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TMRvRb289942
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 18:27:57 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TMRvwC013597
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 18:27:57 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> I can try patch-2.6.18-rc1, etc... to see which one it stops
>> working on to narrow it down.
>
>If you could do this in the meanwhile, it would help us out
>a lot.
>
It stops working in patch-2.6.18-rc1. 

Regards,
Joy
