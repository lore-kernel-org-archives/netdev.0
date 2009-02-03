From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 3/3] iptables: lock free counters (alternate version)
Date: Tue, 03 Feb 2009 13:27:24 -0800
Message-ID: <4988B6BC.70006@hp.com>
References: <20090130215700.965611970@vyatta.com>	<20090130215729.416851870@vyatta.com>	<498594B6.6000905@cosmosbay.com> <20090202153357.3ac6edfa@extreme>	<49889440.60702@cosmosbay.com>	<20090203193214.GH6607@linux.vnet.ibm.com>	<4988A6F4.6000902@cosmosbay.com>	<20090203211000.GI6607@linux.vnet.ibm.com> <20090203132220.21a16ea1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:19375 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbZBCV1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 16:27:30 -0500
In-Reply-To: <20090203132220.21a16ea1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, is this patch stream at a point where I should try running the 32-core 
netperf tests against it?  And if so, against which tree should I try applying 
patches?

rick jones
