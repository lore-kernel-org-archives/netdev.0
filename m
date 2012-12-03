From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] sctp: Add support to per-association
 statistics via a new SCTP_GET_ASSOC_STATS call
Date: Mon, 03 Dec 2012 13:33:12 -0500 (EST)
Message-ID: <20121203.133312.69027699789824133.davem@davemloft.net>
References: <1354373382-15230-1-git-send-email-michele@acksyn.org>
	<50BCD956.2090706@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michele@acksyn.org, linux-sctp@vger.kernel.org,
	nhorman@tuxdriver.com, tgraf@suug.ch, netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904Ab2LCSdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:33:16 -0500
In-Reply-To: <50BCD956.2090706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 03 Dec 2012 11:54:46 -0500

> On 12/01/2012 09:49 AM, Michele Baldessari wrote:
>> The current SCTP stack is lacking a mechanism to have per association
>> statistics. This is an implementation modeled after OpenSolaris'
>> SCTP_GET_ASSOC_STATS.
>>
>> Userspace part will follow on lksctp if/when there is a general ACK on
>> this.
 ...
>> Signed-off: Michele Baldessari <michele@acksyn.org>
> 
> Looks good
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied.
