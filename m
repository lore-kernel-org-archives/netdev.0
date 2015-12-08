From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] mm: memcontrol: account socket memory in unified
 hierarchy v4-RESEND
Date: Tue, 08 Dec 2015 11:28:42 -0500 (EST)
Message-ID: <20151208.112842.1232564665639623347.davem@davemloft.net>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannes@cmpxchg.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue,  8 Dec 2015 10:30:10 -0500

> Hi Andrew,
> 
> there was some build breakage in CONFIG_ combinations I hadn't tested
> in the last revision, so here is a fixed-up resend with minimal CC
> list. The only difference to the previous version is a section in
> memcontrol.h, but it accumulates throughout the series and would have
> been a pain to resolve on your end. So here goes. This also includes
> the review tags that Dave and Vlad had sent out in the meantime.
> 
> Difference to the original v4:

All looks fine to me:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
