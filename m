From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/08: netfilter update
Date: Thu, 25 Feb 2010 18:35:25 +0100
Message-ID: <4B86B4DD.6060006@trash.net>
References: <20100224174927.16391.59798.sendpatchset@x2.localnet> <4B85D42E.5030304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B85D42E.5030304@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shan Wei wrote:
> Patrick McHardy wrote, at 02/25/2010 01:49 AM:
>> Hi Dave,
>>
>> following is the probably final netfilter update for 2.6.34, containing:
> 
> 2.6.33 is just released, and Linus Torvalds said that
> this merger window period is about ten-to-twelve days.
> 
> Is it enough for us to review patch-set with title "IPv6:netfilter: defragment"?
> Is there hope to merger this patch-set for 2.6.34?

The networking merge window closes earlier than that. These
patches are quite small however and almost classify as bugfixes,
so I'm fine with them if you send them over very quickly and
Dave doesn't object.
