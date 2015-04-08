From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH 0/2] hv_netvsc: linearize SKBs bigger than MAX_PAGE_BUFFER_COUNT-2 pages
Date: Wed, 08 Apr 2015 18:47:18 +0200
Message-ID: <874moq4lex.fsf@vitty.brq.redhat.com>
References: <1428508446-18423-1-git-send-email-vkuznets@redhat.com>
	<20150408.122810.2304841162873681785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org,
	devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150408.122810.2304841162873681785.davem@davemloft.net> (David
	Miller's message of "Wed, 08 Apr 2015 12:28:10 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Vitaly Kuznetsov <vkuznets@redhat.com>
> Date: Wed,  8 Apr 2015 17:54:04 +0200
>
>> This patch series fixes the same issue which was fixed in Xen with commit
>> 97a6d1bb2b658ac85ed88205ccd1ab809899884d ("xen-netfront: Fix handling packets on
>> compound pages with skb_linearize").
>
> This patch series only applies on net-next, so that's where I put it.

Yes, it is for net-next, thanks.

>
> Please be completely explicit about this in the future, rather than
> forcing me to try and figure it out.

Sorry, I will, for some reason I thought it was the default.

>
> Thanks.

-- 
  Vitaly
