From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: of 2.6.2-rc2-mm2 and r8169
Date: Sat, 7 Feb 2004 00:17:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207001756.A26645@electric-eye.fr.zoreil.com>
References: <20040130014108.09c964fd.akpm@osdl.org> <20040201100340.GA12436@neuffer.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shuchen@realtek.com.tw
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Neuffer <neuffer@neuffer.info>
Content-Disposition: inline
In-Reply-To: <20040201100340.GA12436@neuffer.info>; from neuffer@neuffer.info on Sun, Feb 01, 2004 at 11:03:40AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Neuffer <neuffer@neuffer.info> :
[...]
> After many tests I was finally able to capture an Oops:
> Oops: 0000 [#1]
> PREEMPT

If you need to see it work better, I would suggest to disable PREEMPT/SMP.

Could you send me the faulty r8169.o module off-list as well as an lsmod, an
output of the /proc/interrupts and a dmesg from boot ?

--
Ueimor
