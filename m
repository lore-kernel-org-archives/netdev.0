From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [update] 2.6.2-rc1 - Realtek 8169 patches
Date: Sat, 24 Jan 2004 11:16:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124111601.A30087@electric-eye.fr.zoreil.com>
References: <20040122234725.A8109@electric-eye.fr.zoreil.com> <200401241522.18369.harisri@bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <harisri@bigpond.com>
Content-Disposition: inline
In-Reply-To: <200401241522.18369.harisri@bigpond.com>; from harisri@bigpond.com on Sat, Jan 24, 2004 at 03:22:18PM +1100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <harisri@bigpond.com> :
[...]
> I have applied your patches (all of them) and the kernel oops when I ping to 
> that machine from a remote machine :-(.

Ok, can you publish/send me offlist an objdump -S of your r8169 module +
r8169.c source ?

[...]
> I will try to track down which one of your patch introduces the regression.

Thanks, a binary search can be done in 5~6 different rounds.

--
Ueimor
