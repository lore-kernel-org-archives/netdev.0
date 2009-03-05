From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 08:12:50 +0100
Message-ID: <49AF7B72.2020905@trash.net>
References: <20090304.225719.159854470.davem@davemloft.net>	<20090304.230023.09984572.davem@davemloft.net>	<49AF79A6.6030002@trash.net> <20090304.231120.86999183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59547 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177AbZCEHMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 02:12:53 -0500
In-Reply-To: <20090304.231120.86999183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 05 Mar 2009 08:05:10 +0100
> 
>> David Miller wrote:
>>> I think this will fix it.
>> Good catch, that looks like a likely cause. Will test in a minute ...
> 
> We probably need both fixes to cover everything.
> 

Yes, just the second one still crashes. I'm about to retry using both.
