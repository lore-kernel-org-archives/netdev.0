From: Greg KH <greg@kroah.com>
Subject: Re: kernel BUG at net/ipv4/tcp_output.c:2748!
Date: Tue, 13 Jun 2017 15:02:46 +0200
Message-ID: <20170613130246.GA23325@kroah.com>
References: <CAJsXRPG5_0q95s_p7yRKT2crU-ghgTMx6ki8mRSg=MkJ58becA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
To: Dison River <pwn2river@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJsXRPG5_0q95s_p7yRKT2crU-ghgTMx6ki8mRSg=MkJ58becA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 13, 2017 at 07:39:00PM +0800, Dison River wrote:
> Hi
>    I've got the following error report while fuzzing the kernel with
> syzkaller on
> linux-4.11.0-rc3.

4.11-rc3 is pretty old now, can you try 4.12-rc4 for this?

thanks,

greg k-h
