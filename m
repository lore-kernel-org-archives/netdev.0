From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NETFILTER]: fix ebtable targets return
Date: Thu, 21 Feb 2008 11:50:07 +0100
Message-ID: <47BD575F.2070505@trash.net>
References: <12035721921230-git-send-email-joonwpark81@gmail.com> <20080220.214533.205446881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080220.214533.205446881.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Joonwoo Park <joonwpark81@gmail.com>
> Date: Thu, 21 Feb 2008 14:36:32 +0900
> 
>> The function ebt_do_table doesn't take NF_DROP as a verdict from the targets.
>>
>> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> 
> Whoops, good catch :-)
> 
> Patrick, if you want you can just signoff on this and I can
> put it directly into my tree.

Good catch indeed, thanks.

Signed-off-by: Patrick McHardy <kaber@trash.net>
