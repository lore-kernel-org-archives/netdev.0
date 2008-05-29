From: Rick Jones <rick.jones2@hp.com>
Subject: Re: network card with LRO (and TSO) in hardware?
Date: Thu, 29 May 2008 10:36:51 -0700
Message-ID: <483EE9B3.80201@hp.com>
References: <200805292004.58064.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:42944 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbYE2Rgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 13:36:54 -0400
In-Reply-To: <200805292004.58064.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> Hi,
> 
> Can you recommend a network card with LRO/TSO support in hardware which is 
> supported in Linux?
> 
> And, do you, by any chance, know what is the maximum number of packets per 
> second that you can obtain with such a setup?

That second bit sounds very much like a "how long is a piece of string" 
question.  What size packets?  What sort of host system(s)?  How many 
concurrent flows/connections etc etc etc...

rick jones
