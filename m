From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [GIT] Networking
Date: Thu, 3 Sep 2015 17:23:19 -0600
Message-ID: <55E8D667.4060409@cumulusnetworks.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150902.223522.1792493140210966693.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/2/15 11:35 PM, David Miller wrote:
>
> Another merge window, another set of networking changes.  I've heard
> rumblings that the lightweight tunnels infrastructure has been voted
> networking change of the year.  But what do I know?
>
...

> 9) Add support for "light weight tunnels", which allow for
>     encapsulation and decapsulation without bearing the overhead of a
>     full blown netdevice.  From Thomas Graf, Jiri Benc, and a cast of
>     others.

Glad to see this feature (among others) hit Linus' tree. An oversight in 
the above is Roopa Prabhu who did the implementation for LWT. Roopa 
deserves direct mention versus part of the 'cast of others'.
