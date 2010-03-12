From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 0/7] tcp: bugs and cleanup for 2.6.34-rc1
Date: Fri, 12 Mar 2010 08:27:26 -0500
Message-ID: <4B9A413E.1030101@gmail.com>
References: <4B98D592.6040301@gmail.com>	 <1268319664.2986.535.camel@edumazet-laptop>  <4B992A89.6040700@gmail.com> <1268331251.17462.51.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?UGVudHRpbMOkIE1pa2E=?= <mika.penttila@ixonos.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268331251.17462.51.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/11/10 1:14 PM, Joe Perches wrote:
> On Thu, 2010-03-11 at 12:38 -0500, William Allen Simpson wrote:
>>> http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=28b2774a0d5852236dab77a4147b8b88548110f1
>
> In that patch, it might be  better to use
> 	u16 s_data_desired = 0;
> not
> 	int s_data_desired = 0;
>
Actually, Eric wrote that part of the message, and that patch.  I expect
that ship has sailed, but you could submit a patch....
