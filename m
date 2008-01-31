From: Patrick McHardy <kaber@trash.net>
Subject: Re: hard hang through qdisc
Date: Thu, 31 Jan 2008 14:29:50 +0100
Message-ID: <47A1CD4E.7050701@trash.net>
References: <200801311321.01015.ak@suse.de> <1201782841.4732.11.camel@localhost> <200801311428.48175.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48763 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763915AbYAaN35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:29:57 -0500
In-Reply-To: <200801311428.48175.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>> ---------
>> lilsol:~# tc qdisc add dev eth0 root tbf rate 1000 burst 10 limit 100
>> lilsol:~# uname -a
>> Linux lilsol 2.6.24 #1 PREEMPT Sun Jan 27 09:22:00 EST 2008 i686
> 
> Can you try it again with current git mainline?


I'll look into it.
