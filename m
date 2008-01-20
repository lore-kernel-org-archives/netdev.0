From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 00/09]: sch_ingress cleanups
Date: Sun, 20 Jan 2008 16:35:01 +0100
Message-ID: <47936A25.9070306@trash.net>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain> <1200843096.4433.145.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60540 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754039AbYATPgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 10:36:02 -0500
In-Reply-To: <1200843096.4433.145.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Sun, 2008-20-01 at 15:32 +0100, Patrick McHardy wrote:
>> These patches clean up sch_ingress by reformatting the code to match the
>> usual kernel style, removing lots of debugging statements that seem
>> unnecessary after years of stable operation, removing some "future use"
>> stuff that doesn't seem likely to ever get used and some minor additional
>> cleanups.
>>
> 
> Patrick - if you are in mopping-mode then you will find some of the same
> things in dsmark (LinuxWay(tm)).


Indeed, that one could use a bit of cleanup as well. I took care
of sch_ingress first since I had these patches queued for multiple
years now and always forgot to send them out, but I'll look into
sch_dsmark next time I'm in the area :)

> For all patches:
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>


Thanks.
