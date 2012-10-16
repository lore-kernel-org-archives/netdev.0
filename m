From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix call to SCTP_CMD_PROCESS_SACK in
 sctp_cmd_interpreter()
Date: Tue, 16 Oct 2012 14:56:11 -0400 (EDT)
Message-ID: <20121016.145611.1344400917557072925.davem@davemloft.net>
References: <1350309399-23422-1-git-send-email-nicolas.dichtel@6wind.com>
	<507C2E76.3030801@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, zijie.pan@6wind.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2JPS4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 14:56:14 -0400
In-Reply-To: <507C2E76.3030801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 15 Oct 2012 11:40:38 -0400

> On 10/15/2012 09:56 AM, nicolas.dichtel@6wind.com wrote:
>> From: Zijie Pan <zijie.pan@6wind.com>
>>
>> Bug introduced by commit edfee0339e681a784ebacec7e8c2dc97dc6d2839
>> (sctp: check src addr when processing SACK to update transport state)
>>
>> Signed-off-by: Zijie Pan <zijie.pan@6wind.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Shutdown case..  ACK.
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied.
