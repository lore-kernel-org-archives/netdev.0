From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: igmp broadcast storm Red Hat EL7 3.1 Kernel
Date: Mon, 31 Aug 2015 09:48:32 -0700
Message-ID: <CAM_iQpUTCpG3YeSvuJTdNAuAjoBObcObYNGKeHrbfR4g+5B7yA@mail.gmail.com>
References: <CA+ekxPUBfhBTXwfO1=M3f6siqieBgJsiHs2DbJfgC72ogu3UZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jeffrey Merkey <jeffmerkey@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ekxPUBfhBTXwfO1=M3f6siqieBgJsiHs2DbJfgC72ogu3UZw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev)

On Sat, Aug 29, 2015 at 3:50 PM, Jeffrey Merkey <jeffmerkey@gmail.com> wrote:
> When installing Centos 7 running kernel 3.1 (Centos 7 distro) the
> system generates an igmp broadcast storm which locks up and knocks
> down a Century Link DSL router.  Powering the router off clears the
> broadcast storm.
>
> The bug is kernel related and resembles very closely another bug seen
> about 10 years ago with Caldera's distro's on 2.4.  The bug occurs on
> the ia32 beta build.  The bug DOES NOT exist in the 64 bit x86_64
> versions.    I will attempt to debug it further since I have my own
> debugger and try to run it down and provide more info.
>

A reproducer and/or bisect would help a lot.

Thanks.
