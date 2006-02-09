From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed
Date: Wed, 8 Feb 2006 18:10:21 -0800
Message-ID: <4807377b0602081810l55e4cbdfyeb9102bd50d04641@mail.gmail.com>
References: <e282236e0602070146p1ed3fdb6k74aa75e15bbc37a3@mail.gmail.com>
	 <4807377b0602081207s7604eceahb8bf4af6715a6534@mail.gmail.com>
	 <20060208.141205.129707967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: yoseph.basri@gmail.com, bb@kernelpanic.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422771AbWBICKZ@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060208.141205.129707967.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/8/06, David S. Miller <davem@davemloft.net> wrote:
> From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
> Date: Wed, 8 Feb 2006 12:07:14 -0800
>
> > this should be on netdev (cc'd), i included some of the thread here.
>  ...
> > I though Herbert had fixed these, and it looks like half the patches
> > got into 2.6.14.3, but not the fix to the fix committed on 9-6 (not in
> > 2.6.14.* at all)
>
> What are the changeset IDs so I can fix this?

I think the commit id that is missing from 2.6.14.X is
fb5f5e6e0cebd574be737334671d1aa8f170d5f3

but here is the web link if i gave the wrong info
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=fb5f5e6e0cebd574be737334671d1aa8f170d5f3
