From: Andrew Morton <akpm@osdl.org>
Subject: Re: dst cache overflow
Date: Mon, 21 Mar 2005 19:40:22 -0800
Message-ID: <20050321194022.491060c7.akpm@osdl.org>
References: <1144.192.168.0.37.1111351868.squirrel@buakaw.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: buakaw@buakaw.homelinux.net
In-Reply-To: <1144.192.168.0.37.1111351868.squirrel@buakaw.homelinux.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

buakaw@buakaw.homelinux.net wrote:
>
> the system become very laggy.
> i use kernel 2.6.10/2.6.11.3 on p4 2.8, msi915p, 3 x 3com905 boomerang.
> and the cpu usage normally be about 12% and after something happens it
> boost to 100% and it is used mostly by ksoftirqd/0, and a little bit by 
> migration/0 and event/0. and in syslog i found thies lines
> 
> Mar 20 22:21:09 buakaw kernel: printk: 5543 messages suppressed.
> Mar 20 22:21:09 buakaw kernel: dst cache overflow
> 
> what can cause this?

Could you please describe the workload?  What is the computer doing at the
time, and how is it set up?

Thanks.
