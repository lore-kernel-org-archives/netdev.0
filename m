From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netns: simplify net_ns_init
Date: Thu, 21 May 2009 15:10:40 -0700 (PDT)
Message-ID: <20090521.151040.07804750.davem@davemloft.net>
References: <20090521135846.1fadbe41@nehalam>
	<20090521140042.201351d7@nehalam>
	<m1bppmqgns.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34955
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755270AbZEUWKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 18:10:41 -0400
In-Reply-To: <m1bppmqgns.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 21 May 2009 14:39:51 -0700

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
>> The net_ns_init code can be simplified. No need to save error code
>> if it is only going to panic if it is set 4 lines later.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
