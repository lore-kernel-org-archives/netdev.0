From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 11/12] NET: fix subqueue bugs
Date: Tue, 23 Oct 2007 18:40:10 -0400
Message-ID: <471E784A.5090303@garzik.org>
References: <tueoct232007613pm.likjasfdlkjdas987@havoc.gtf.org>	<20071023223646.550241F81B7@havoc.gtf.org> <20071023.153836.85407923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756644AbXJWWlj@vger.kernel.org>
In-Reply-To: <20071023.153836.85407923.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Tue, 23 Oct 2007 18:36:46 -0400 (EDT)
> 
>> net/sched/sch_prio.c: In function $,1rxprio_dequeue$,1ry:
>> net/sched/sch_prio.c:139: warning: passing argument 2 of $,1rxnetif_subqueue_stopped$,1ry makes pointer from integer without a cast
>> net/sched/sch_prio.c: In function $,1rxrr_dequeue$,1ry:
>> net/sched/sch_prio.c:169: warning: passing argument 2 of $,1rxnetif_subqueue_stopped$,1ry makes pointer from integer without a cast
>>
>> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> 
> I have another copy of this from Pavel earlier in my inbox
> and I promise I will integrate his patch today :-)

Either way, all good :)  Just dumping my fixes from last night.

	Jeff
