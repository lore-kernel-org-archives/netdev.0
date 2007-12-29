From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Top 9 kernel oopses/warnings for the week of December 29th, 2007
Date: Sat, 29 Dec 2007 20:31:08 +0100
Message-ID: <4776A07C.5090806@linux.intel.com>
References: <477630CF.5070609@linux.intel.com> <alpine.LFD.0.9999.0712291116190.2778@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:8828 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750948AbXL2Tc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 14:32:59 -0500
In-Reply-To: <alpine.LFD.0.9999.0712291116190.2778@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds wrote:
> 
> On Sat, 29 Dec 2007, Arjan van de Ven wrote:
>> It has been a quiet week due to the holidays, only 55 oops traces
>> have been collected.
> 
> This would be more useful if it was more readable. As it is, you seem to 
> have some formatting errors in your automation, where the things are 
> incorrectly grouped:

this is manual made; I'll blame thunderbird for now

let me see if I can send it again without corruption

> 
>> Rank 1: sysctl_head_finish
>> 	sysctl table check failed
>> 	Reported 7 times
>> 	Only reported for the proprietary madwifi driver
>> 	More info: http://www.kerneloops.org/search.php?search=sysctl_head_finish
>> 	Rank 2: __ieee80211_rx
>> 	Warning at net/mac80211/rx.c:1672
> 
> ie notice how that "Rank 2" got reported as if it was part of the "Rank 1" 
> issue. 
> 
> 		Linus

