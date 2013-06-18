From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Two SCTP cleanup patches
Date: Mon, 17 Jun 2013 17:08:26 -0700 (PDT)
Message-ID: <20130617.170826.676615336737500846.davem@davemloft.net>
References: <1371462005-19310-1-git-send-email-dborkman@redhat.com>
	<51BF1576.4080203@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3FRAI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:08:27 -0400
In-Reply-To: <51BF1576.4080203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 17 Jun 2013 09:56:06 -0400

> On 06/17/2013 05:40 AM, Daniel Borkmann wrote:
>> Two cleanup-only patches to make the code more readable and consistent
>> with the rest of the kernel code.
>>
>> Daniel Borkmann (2):
>>    net: sctp: get rid of t_new macro for kzalloc
>>    net: sctp: remove SCTP_STATIC macro
>>
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Series applied, thanks everyone.
