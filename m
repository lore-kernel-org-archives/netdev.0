From: David Miller <davem@davemloft.net>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Mon, 20 Apr 2009 02:15:37 -0700 (PDT)
Message-ID: <20090420.021537.114818208.davem@davemloft.net>
References: <20090416214846.GA9375@ami.dom.local>
	<20090417.050422.134655407.davem@davemloft.net>
	<200904171250.02258.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: alexandre.sidorenko@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48375
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752571AbZDTJPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:15:45 -0400
In-Reply-To: <200904171250.02258.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Date: Fri, 17 Apr 2009 12:50:02 -0400

> On April 17, 2009 08:04:22 am David Miller wrote:
>> Meanwhile, Alexandre can you test Jarek's patch for your case?
> 
> I have applied Jarek's patch to 2.6.29.1 and tested with 'ping'. Everything 
> works fine.

Ok I'll add Jarek's patch to the tree, thanks for testing.
