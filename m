From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 10/10 REV5] [E1000] Implement batching
Date: Wed, 14 Nov 2007 14:00:15 +0530
Message-ID: <OF10FB1515.27A9A529-ON65257393.002E9CC9-65257393.002EB706@in.ibm.com>
References: <473A16EE.6080101@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:38033 "EHLO
	e28esmtp02.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752008AbXKNI2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 03:28:38 -0500
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id lAE8S2dW004793
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 13:58:02 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAE8S2r14296706
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 13:58:02 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id lAE8S2Ff023519
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 08:28:02 GMT
In-Reply-To: <473A16EE.6080101@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Auke,

"Kok, Auke" <auke-jan.h.kok@intel.com> wrote on 11/14/2007 02:58:14 AM:

> this doesn't apply anymore and it would help if you could re-spin this
for e1000e.
> I don't know what the status for merging of the batched xmit patches is
right now
> but it would help if you could rewrite them against e1000e, which I
assume is what
> most people want to test with. There are also significant changes
upstream right
> now in jgarzik/netdev-2.6 #upstream...
>
> I'm still very interested in these patches BTW.

I will make a latest version and test it out for some numbers and try to
send it this week.

Thanks,

- KK

