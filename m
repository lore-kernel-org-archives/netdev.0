From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH net-next 1/2] cxgb3: move away from LLTX
Date: Fri, 29 May 2009 13:28:04 -0700
Message-ID: <4A204554.8070808@chelsio.com>
References: <20090529075823.30669.28885.stgit@speedy5> <20090529.015747.109057209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765138AbZE2U3o@vger.kernel.org>
In-Reply-To: <20090529.015747.109057209.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Divy Le Ray <divy@chelsio.com>
> Date: Fri, 29 May 2009 00:58:24 -0700
>
>   
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> cxgb3 no longer advertizes LLTX.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>>     
>
> You might want to mention that these two patches depend
> upon the 2.6.30 cxgb3 patches you also submitted at this
> time and aren't in the tree yet. :-/
>   

Sorry about that. It actually conflicts with Eric Dumazet's trans_start 
removal patch.
I'll resubmit the net-next patches, refreshed on op of Eric's patch.
I also verified that the 2.6.30 cxgb3 patches apply
before or after the cxgb3 net-next series is applied.

Cheers,
Divy
