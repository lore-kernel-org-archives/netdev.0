From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Tue, 20 Jan 2004 00:24:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040120002422.A19029@electric-eye.fr.zoreil.com>
References: <200401152039.00182.harisri@bigpond.com> <20040115220827.A22007@electric-eye.fr.zoreil.com> <200401192251.41323.harisri@bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <harisri@bigpond.com>
Content-Disposition: inline
In-Reply-To: <200401192251.41323.harisri@bigpond.com>; from harisri@bigpond.com on Mon, Jan 19, 2004 at 10:51:41PM +1100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <harisri@bigpond.com> :
[vmstat 1 output]

Ok, mostly idle.

[...]
> > You can try 2.6.1-bk2 + Jeff Garzik's -netdev4 +
> > http://www.fr.zoreil.com/people/francois/misc/r8169-tx-index-overflow.patch
> 
> The r8169-tc-index-overflow.patch does not (cleanly) apply on 2.6.1-bk2 + 
> netdev4.

Can you verify that your kernel tree is fine or give an (sh-)history of
the applied patches ?

I have just checked and the patch applies cleanly on kernel 2.6.1-bk2 +
Jeff's 2.6.1-bk1-netdev4 as well as on kernel 2.6.1-bk4 + Jeff's
2.6.1-bk4-netdev1. 

--
Ueimor
