From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Thu, 22 Jan 2004 21:32:06 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401222132.07355.harisri@bigpond.com>
References: <200401152039.00182.harisri@bigpond.com> <200401212115.45027.harisri@bigpond.com> <20040122005940.A26438@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040122005940.A26438@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Francois,

On Thursday 22 January 2004 10:59, Francois Romieu wrote:
> [...]
> r8169 did not evolve between 2.6.1 and 2.6.2-rc1. Change of behavior
> probably comes from some other part of the kernel. Joy.
>
> > If you want me to I can test your r8169-tc-index-overflow.patch.
>
> See attachment. It applies against plain 2.6.2-rc1.

OK. I have applied your patch and I have tested my computer under moderate to 
high network load. Although I may not have the kind of network load to 
trigger the bug your patch is meant to attack, I can confirm there is no 
stability issue with your patch.

Thanks
Hari
