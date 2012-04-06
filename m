From: John Keeping <john@keeping.me.uk>
Subject: Re: [PATCH] net/core: Fix seeking in /proc/net/dev
Date: Fri, 06 Apr 2012 18:19:39 +0000
Message-ID: <18418e8c2d06fb2a2d4d2cee97035ac9@ctrlfr34k.dyndns.org>
References: <1333731944-15808-1-git-send-email-john@keeping.me.uk>
 <20120406.131800.651812823796333479.davem@davemloft.net>
 <1333734192.3007.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <mihai.maruseac@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333734192.3007.5.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06.04.2012 17:43, Eric Dumazet wrote:
> On Fri, 2012-04-06 at 13:18 -0400, David Miller wrote:
>> Eric Dumazet already fixed this the other day.
>> --
>
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commit;h=2def16ae6b0c77571200f18ba4be049b03d75579

This does indeed fix the same bug.  That will teach me not to check the 
appropriate maintainer's tree before sending a patch!

Sorry for the noise,

John
