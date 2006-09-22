From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 2.6.16.19 2/2] LARTC: trace control for netem: kernelspace
Date: Fri, 22 Sep 2006 17:19:06 +0200
Message-ID: <20060922151906.GA25483@c3po.0xdef.net>
References: <45137F71.2000404@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@VGER.KERNEL.ORG,
	netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
To: Rainer Baumann <baumann@tik.ee.ethz.ch>
Content-Disposition: inline
In-Reply-To: <45137F71.2000404@tik.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Rainer Baumann | 2006-09-22 08:15:13 [+0200]:

>Patch for linux kernel 2.6.16.19: http://tcn.hypert.net/tcnKernel_procfs.patch

Coding Style need at least some work ...

Whitespaces around operators and parentheses, useless parentheses, braces for
the else branch, mixes C99/C89 comments, indentation,  ....

proc_read_stats() look unclean (bzero) and maybe some other stuff too - the
code at a whole look a little bit grubby.

HGN



-- 
43rd Law of Computing:
        Anything that can go wr
fortune: Segmentation violation -- Core dumped
