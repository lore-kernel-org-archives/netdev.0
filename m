From: Joy Latten <latten@austin.ibm.com>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Wed, 7 Feb 2007 10:33:41 -0600
Message-ID: <200702071633.l17GXf2q013208@faith.austin.ibm.com>
Cc: herbert@gondor.apana.org.au, jmorris@namei.org,
	netdev@vger.kernel.org, paul.moore@hp.com, vyekkirala@TrustedCS.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:36013 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965650AbXBGQs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 11:48:57 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l17Gmt6r004849
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 11:48:55 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l17Gmu5C280500
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 11:48:56 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l17GmtLU018577
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 11:48:55 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Joy Latten <latten@austin.ibm.com>
>Date: Mon, 05 Feb 2007 14:53:39 -0600
>
>> I can run some tests with this patch and report any results... 
>
>Please check out the two most recent patches I posted:
>
>1) Updated core patch with ipv6 side added.
>2) Fix for thinko noticed by Venkat.

Just a quick update. I have patched an lspp kernel and 
latest kernel.org kernel. I have been using them alternately
while doing some minor testing and have not found any problems.
Over the next few days, I plan to run a few stress tests for 
labeled ipsec and regular ipsec and will do so with the patched
lspp kernel.  I will also try with kernel.org kernel.
It may take a few days. 

Regards,
Joy
