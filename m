From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [-mm patch] remove net/core/skbuff.c:skb_queue_lock_key
Date: Sat, 15 Jul 2006 07:35:16 +0200
Message-ID: <44B87E94.7000602@linux.intel.com>
References: <20060713224800.6cbdbf5d.akpm@osdl.org> <20060715003519.GF3633@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:11476 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S932500AbWGOFhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 01:37:16 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060715003519.GF3633@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Thu, Jul 13, 2006 at 10:48:00PM -0700, Andrew Morton wrote:
>> ...
>> Changes since 2.6.18-rc1-mm1:
>> ...
>> +lockdep-split-the-skb_queue_head_init-lock-class.patch
>>
>>  lockdep-versus-net fix.
>> ...
> 
> skb_queue_lock_key is no longer used.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 

Acked-by: Arjan van de Ven <arjan@linux.intel.com>
