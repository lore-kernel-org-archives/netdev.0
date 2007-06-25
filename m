From: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2 - rev2] qdisc_restart - readability changes plus
	onebug fix.
Date: Mon, 25 Jun 2007 08:18:32 +0530
Message-ID: <1182739713.7611.1.camel@localhost.localdomain>
References: <D5C1322C3E673F459512FB59E0DDC329030D56EB@orsmsx414.amr.corp.intel.com>
	 <OF1879284F.48E1D196-ON652572FF.00137810-652572FF.0013BA3A@in.ibm.com>
	 <20070618.205831.112607946.davem@davemloft.net>
	 <1182269729.4968.57.camel@localhost>
Reply-To: kumarkr@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	kaber@trash.net, netdev@vger.kernel.org, tgraf@suug.ch
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:49299 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbXFYCrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 22:47:45 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5P2mx7G6746322
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 12:48:59 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5P2p6TK164474
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 12:51:07 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5P2lW6M012140
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 12:47:34 +1000
In-Reply-To: <1182269729.4968.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal, Dave (and anyone else interested),

Could you review this patch ?

Thanks,

- KK


On Tue, 2007-06-19 at 12:15 -0400, jamal wrote:
> On Mon, 2007-18-06 at 20:58 -0700, David Miller wrote:
> > From: Krishna Kumar2 <krkumar2@in.ibm.com>
> > Date: Tue, 19 Jun 2007 09:05:28 +0530
> > 
> > > Dave, does it make sense to add this to 2.6.23 ? Herbert and Peter
> > > had earlier reviewed Patch 2/2 and said they were OK with it.
> > 
> > What does Jamal think of it :-)
> 
> I think Krishna has worked hard and produced the patches - and given the
> wisdom of crowds - the patches deserve to go in.
> I dont have the proper energy to review at the moment (I am a
> conservative when touching that area of the code) - Thomas do you have
> time? I will have time end of week.
> 
> cheers,
> jamal
> 

