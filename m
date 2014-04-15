From: Vincenzo Maffione <v.maffione@gmail.com>
Subject: Re: [PATCH] drivers: net: xen-netfront: remove unused arrays
Date: Tue, 15 Apr 2014 20:46:43 +0200
Message-ID: <CA+_eA9gAqyKyFXbGZpUQiDqA2jVWAWUbE3cbeXhRtSFZGmh3jg@mail.gmail.com>
References: <1397583579-32162-1-git-send-email-v.maffione@gmail.com>
	<534D7244.5000002@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <534D7244.5000002@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-04-15 19:54 GMT+02:00 David Vrabel <david.vrabel@citrix.com>:
> On 15/04/14 18:39, Vincenzo Maffione wrote:
>> This patch removes some unused arrays from the netfront
>> private data structure.
>> Also removes an unused address variable.
>>
>> Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>
>
> Huh. I wonder what they were for.
>
> Acked-by: David Vrabel <david.vrabel@citrix.com>
>
> For net related patches please say whether they're for the net (current
> RCs) or net-next branch.  e.g.,
>
> [PATCH net-next] xen-netfront: removed unused arrays.
>
Ok, thanks.

I used linux-next
   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
but I don't really know what is the most appropriate.
(I guess git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git is "net"?)

Vincenzo

> Thanks.
>
> David



-- 
Vincenzo Maffione
