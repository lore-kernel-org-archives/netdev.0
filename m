From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Wed, 07 Feb 2007 09:16:11 +0100
Message-ID: <45C98ACB.1080107@trash.net>
References: <20070206215806.GA5109@elte.hu>	<45C974FD.5070404@trash.net>	<20070207080722.GC2434@elte.hu> <20070207.001310.91210854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, akpm@linux-foundation.org, netdev@vger.kernel.org,
	dipankar@in.ibm.com, paulmck@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43135 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030188AbXBGIQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 03:16:16 -0500
In-Reply-To: <20070207.001310.91210854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 7 Feb 2007 09:07:22 +0100
> 
> 
>>Dave, Patrick, can we lift the nack on PREEMPT_RCU, as far as networking 
>>goes?
> 
> 
> After Patrick's fixups, sure.


I'm about to send my queued netfilter patches, after which I will look
into this. Shouldn't take more than a one or two days.

