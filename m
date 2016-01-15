From: David Miller <davem@davemloft.net>
Subject: Re: [requrest for stable 4.1.y inclution] Fix for CVE-2015-7799
Date: Fri, 15 Jan 2016 16:01:01 -0500 (EST)
Message-ID: <20160115.160101.1790770055744457023.davem@davemloft.net>
References: <56978CFE.1010703@jp.fujitsu.com>
	<1452777529.7020.67.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: machida.yuki@jp.fujitsu.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbcAOVBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 16:01:03 -0500
In-Reply-To: <1452777529.7020.67.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 14 Jan 2016 13:18:49 +0000

> On Thu, 2016-01-14 at 20:56 +0900, Yuki Machida wrote:
>> This patch is the fix for CVE-2015-7799
>> Upstream commit 4ab42d78e37a294ac7bc56901d563c642e03c4ae
>> 
>> Stable 3.2.y has included this patch in v3.2.75.
>> https://cdn.kernel.org/pub/linux/kernel/v3.x/ChangeLog-3.2.75
>> 
>> Please include in this patch to stable 4.1.y.
> 
> Commit 0baa57d8dc32db78369d8b5176ef56c5e2e18ab3 is also needed as
> preparation.

Noted, thanks Ben.
