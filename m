From: David Miller <davem@davemloft.net>
Subject: Re: A Linux TCP SACK Question
Date: Thu, 17 Apr 2008 23:52:57 -0700 (PDT)
Message-ID: <20080417.235257.06267707.davem@davemloft.net>
References: <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
	<20080416.023551.70464279.davem@davemloft.net>
	<000201c89fd1$308edf30$6b5ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, johnwheffner@gmail.com,
	netdev@vger.kernel.org
To: wenji@fnal.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40494
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754762AbYDRGw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 02:52:56 -0400
In-Reply-To: <000201c89fd1$308edf30$6b5ee183@D2GT6T71>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wenji Wu <wenji@fnal.gov>
Date: Wed, 16 Apr 2008 09:50:19 -0500

> >I've added John's patch to net-2.6.26
> 
> I just tried with John's patch. It works, saturating the 1Gbps in my test. 
> 
> Without the patch, the throughput is around 180Mbps with SACK On, 250Mbps
> with SACK off.
> 
> The same test environment described in my previous emails.

After this patch cooks for a couple more days I'll submit it
to -stable.

Thanks for your report and all of your testing Wenji.

Thanks John for the patch.
