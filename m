From: kuznet@ms2.inr.ac.ru
Subject: Re: kernel panic: bug in sch_sfq.c
Date: Tue, 11 Mar 2003 19:08:18 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200303111608.TAA13074@sex.inr.ac.ru>
References: <20030311155409.GB7641@oasis.frogfoot.net>
Mime-Version: 1.0
Cc: devik@cdi.cz, ahu@ds9a.nl, linux-kernel@vger.kernel.org,
   david@uninetwork.co.za, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: abz@frogfoot.net (Abraham van der Merwe)
In-Reply-To: <20030311155409.GB7641@oasis.frogfoot.net> from "Abraham van der Merwe" at Mar 11, 3 05:54:09 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Also, if I compile the kernel with all debugging enabled (CONFIG_DEBUG_SLAB,
> etc) I can reliably trigger the BUG() on line 1263 in mm/slab.c

How does backtrace oops look?

Alexey
