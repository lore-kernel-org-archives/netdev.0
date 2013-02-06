From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH v4 1/1 net-next] net: fec: add napi support to improve proformance
Date: Wed, 6 Feb 2013 00:16:33 +0000 (UTC)
Message-ID: <loom.20130206T011451-752@post.gmane.org>
References: <1359433903-15605-1-git-send-email-Frank.Li@freescale.com> <20130129.141800.2181207237672109119.davem@davemloft.net> <CAHrpEqQXH+n7K4L1m5yRiamp3CG9MPWhX+tNBD+brzArJy5WoQ@mail.gmail.com> <loom.20130204T203257-683@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60432 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753729Ab3BFARB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 19:17:01 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U2shR-0005Cn-6v
	for netdev@vger.kernel.org; Wed, 06 Feb 2013 01:17:17 +0100
Received: from jimbax.plus.com ([81.174.248.107])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 01:17:17 +0100
Received: from jim_baxter by jimbax.plus.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 01:17:17 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jim Baxter <jim_baxter <at> mentor.com> writes:

> 
> This might be related but I have found on the Sabre AI Revision TO1.1 that the 
> NAPI patch causes a 10% reduction in speed, is this expected?
> 
> 

Hi, after some investigation I have found that there is a speed up.
Sorry for my mistake.
