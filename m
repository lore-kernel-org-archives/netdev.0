From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] smc911x: Fix external PHY detection
Date: Sun, 12 Oct 2008 09:43:00 +0200
Message-ID: <87r66m2r97.fsf@macbook.be.48ers.dk>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
	<87vdx5gjzo.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810110125540.10196@axis700.grange>
	<871vynr3yb.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810111057030.4425@axis700.grange>
	<87k5cfoz7b.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810112309410.4965@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Guennadi Liakhovetski <lg@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:13456 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbYJLHnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 03:43:03 -0400
Received: by nf-out-0910.google.com with SMTP id d3so524255nfc.21
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 00:43:01 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810112309410.4965@axis700.grange> (Guennadi Liakhovetski's message of "Sat\, 11 Oct 2008 23\:10\:58 +0200 \(CEST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:

 Guennadi> If an external PHY is found the driver falls through to the
 Guennadi> default case in the switch and overwrites the PHY ID. Add
 Guennadi> the missing break.

 Guennadi> Signed-off-by: Guennadi Liakhovetski <lg@denx.de>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
