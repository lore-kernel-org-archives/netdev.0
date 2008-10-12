From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH v2] smc911x: Add support for LAN921{5,7,8} chips from SMSC
Date: Sun, 12 Oct 2008 09:54:08 +0200
Message-ID: <87myha2qqn.fsf@macbook.be.48ers.dk>
References: <Pine.LNX.4.64.0810111057030.4425@axis700.grange>
	<87k5cfoz7b.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810112311030.4965@axis700.grange>
	<20081011.150852.73771267.davem@davemloft.net>
	<Pine.LNX.4.64.0810120058190.4965@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Steve.Glendinning@smsc.com,
	netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Guennadi Liakhovetski <lg@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:22083 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbYJLHyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 03:54:15 -0400
Received: by nf-out-0910.google.com with SMTP id d3so524820nfc.21
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 00:54:14 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810120058190.4965@axis700.grange> (Guennadi Liakhovetski's message of "Sun\, 12 Oct 2008 00\:59\:44 +0200 \(CEST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:

 Guennadi> LAN92{5,7,8} chips from SMSC are register compatible with
 Guennadi> LAN911{5,6,7,8} controllers, and only add support for HP
 Guennadi> Auto-MDIX. LAN9218 doesn't have an external MII interface.

 Guennadi> Signed-off-by: Guennadi Liakhovetski <lg@denx.de>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
