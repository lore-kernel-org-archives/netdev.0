From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 1/2 - rev2] qdisc_restart - readability changes plus onebug fix.
Date: Tue, 19 Jun 2007 09:30:33 +0530
Message-ID: <OF291ADE92.99055132-ON652572FF.0015F7D9-652572FF.001605EF@in.ibm.com>
References: <20070618.205831.112607946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au, kaber@trash.net,
	kumarkr@linux.vnet.ibm.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:52702 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765003AbXFSD7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 23:59:55 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5J410sZ2064598
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 14:01:00 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5J43Mcx203614
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 14:03:23 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5J3xn7F030713
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 13:59:50 +1000
In-Reply-To: <20070618.205831.112607946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I have copied him in these patches, so he doesn't have to read the netdev
to get them :)

- KK

David Miller <davem@davemloft.net> wrote on 06/19/2007 09:28:31 AM:

> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Tue, 19 Jun 2007 09:05:28 +0530
>
> > Dave, does it make sense to add this to 2.6.23 ? Herbert and Peter
> > had earlier reviewed Patch 2/2 and said they were OK with it.
>
> What does Jamal think of it :-)

