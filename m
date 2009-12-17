From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: IP policy routing & rule 0
Date: Thu, 17 Dec 2009 22:43:21 +0200
Message-ID: <200912172243.21553.opurdila@ixiacom.com>
References: <4B2A7593.4040607@digadd.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Christian P. Schmidt" <schmidt@digadd.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:4795 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759939AbZLQUqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 15:46:39 -0500
In-Reply-To: <4B2A7593.4040607@digadd.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 17 December 2009 20:16:51 you wrote:
> Hi,
> 
> I'm trying to set up a test where I use a single PC to send traffic
> across an external device (router, firewall, etc) and back to the same PC.
> 

I think a patch that makes this possible was submitted a few days ago:

http://www.spinics.net/lists/netdev/msg114702.html

