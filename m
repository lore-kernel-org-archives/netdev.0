From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712
 devices)
Date: Thu, 9 Dec 2010 16:49:25 +0200
Message-ID: <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry>
 <20101129060114.GC29904@auslistsprd01.us.dell.com>
 <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <20101206173534.GC13628@auslistsprd01.us.dell.com>
 <4CFD29BE.2060201@chelsio.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Dimitris Michailidis" <dm@chelsio.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: "Matt Domsch" <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4560 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab0LIOtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 09:49:47 -0500
In-Reply-To: <4CFD29BE.2060201@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-06 at 10:21 -0800, Dimitris Michailidis wrote:
> Matt Domsch wrote:
...
> /sys/class/net/<ifname>/dev_id indicates the physical port <ifname> is 
> associated with.  At least a few drivers set up dev_id this way.
> 
> 

So we are on agreement? This can satisf all needs? If so, we will add
this scheme to the bnx2x as well.

Thanks,
Eilon


