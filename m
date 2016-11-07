From: Eric Leblond <eric@regit.org>
Subject: Re: [PATCH 7/8] tools lib bpf: fix maps resolution
Date: Mon, 07 Nov 2016 13:40:39 -0500
Message-ID: <1478544039.13425.11.camel@regit.org>
References: <20161016211834.11732-1-eric@regit.org>
         <20161016211834.11732-8-eric@regit.org> <5820C6BE.9080300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        Joe Stringer <joe@ovn.org>
To: "Wangnan (F)" <wangnan0@huawei.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5820C6BE.9080300@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, 2016-11-08 at 02:23 +0800, Wangnan (F) wrote:
> Hi Eric,
> 
> Are you still working in this patch set?

Sorry to lag on this, I've been taken by a series of other projects. I
did not yet reworked it yet but I was planning to do a bit on it this
week.

> 
> Now I know why maps section is not a simple array
> from a patch set from Joe Stringer:
> 
> https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
> 
> So I think this patch is really useful.
> 
> Are you going to resend the whole patch set? If not, let me collect
> this patch 7/8 into my local code base and send to Arnaldo
> with my other patches.

If ok with you, I propose that you collect patch 7/8 it you have no
news from me on Friday. If an issue for you, just collect it now and I
will synchronize with updated code when resending my patchset.

BR,
-- 
Eric Leblond <eric@regit.org>
Blog: https://home.regit.org/
