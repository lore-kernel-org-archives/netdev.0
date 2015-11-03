From: David Miller <davem@davemloft.net>
Subject: Re: Resource leak in unshare
Date: Mon, 02 Nov 2015 22:55:31 -0500 (EST)
Message-ID: <20151102.225531.215294199994277493.davem@davemloft.net>
References: <1446508987.23275.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446512899.23275.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446513404.23275.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, steffen.klassert@secunet.com,
	dvyukov@google.com, nicolas.dichtel@6wind.com,
	viro@zeniv.linux.org.uk, tgraf@suug.ch, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, edumazet@google.com, keescook@google.com,
	jln@google.com, sasha.levin@oracle.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446513404.23275.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2015 17:16:44 -0800

> On Mon, 2015-11-02 at 17:08 -0800, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
> 
> Erm, patch title would be :
> 
> [PATCH] sit: fix sit0 percpu double allocations

:-)  Applied and queued up for -stable.
