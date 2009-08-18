From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Tue, 18 Aug 2009 22:16:45 +0530
Message-ID: <OF805DA786.CBBC0216-ON65257616.005BE42E-65257616.005C2BB4@in.ibm.com>
References: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>	<20090814213643.GA3179@ami.dom.local> <20090817.190343.49229178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:43709 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759329AbZHRQqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 12:46:37 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7IGkbAD029636
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2009 22:16:37 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7IGkbcm2519188
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2009 22:16:37 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7IGkaO9002058
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 02:46:36 +1000
Received: from d23ml172.in.ibm.com (d23ml172.in.ibm.com [9.124.105.37])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVin) with ESMTP id n7IGkaeF002054
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 02:46:36 +1000
In-Reply-To: <20090817.190343.49229178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry about the delay, I am sick with the flu for the last few days.
I will send the patch tomorrow.

thanks,

- KK

David Miller <davem@davemloft.net> wrote on 08/18/2009 07:33:43 AM:

> David Miller <davem@davemloft.net>
> 08/18/2009 07:33 AM
>
> To
>
> jarkao2@gmail.com
>
> cc
>
> Krishna Kumar2/India/IBM@IBMIN, kaber@trash.net, netdev@vger.kernel.org,
> herbert@gondor.apana.org.au
>
> Subject
>
> Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
>
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 14 Aug 2009 23:36:43 +0200
>
> > I definitely can't see a reason to make this variable public, and
> > prefer the private (v2) version (which still lacks a changelog, btw).
>
> I'm fine with patch v2, but yes it needs to be properly submitted
> with a real changelog before I can apply it :-)

