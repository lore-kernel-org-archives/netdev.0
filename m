From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: Re: Re: Re: (no subject)
Date: 24 Feb 2003 05:27:04 -0000
Sender: linux-mips-bounce@linux-mips.org
Message-ID: <20030224052704.30149.qmail@webmail29.rediffmail.com>
Reply-To: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed
Cc: macro@ds2.pg.gda.pl, netdev@oss.sgi.com, linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org



On Mon, 24 Feb 2003 Randy.Dunlap wrote :
> >
> >
> > On Sat, 22 Feb 2003 Maciej W. Rozycki wrote :
> >>On 21 Feb 2003, santosh kumar gowda wrote:
> >>
> >> > Following message is produced at the IAD terminal.....
> >> >
> >> > # Unable to handle kernel paging request at virtual 
>address
> >> > 00000000, epc == 802
> >> > 4ce74, ra == 802592a8
> >> > Oops in fault.c:do_page_fault, line 172:
> >>[...]
> >> > Suggestions/Tips are welcome.
> >>
> >>  Decode the oops first or nobody will be able to give any
> >>help.
> >
> > how do i decode the oops ??? help pls.
>
>Please see linux/REPORTING-BUGS and
>linux/Documentation/oops-tracing.txt .
>The latter will tell you how to use use 'ksymoops'
>to decode an oops message.

The Embedded Linux running on my MIPS based device has following 
cmds...

kallsyms  kill      killall   klogd     ksyms

Also, Flash ROM of the device is loaded with kernel and 
filesystem
images. so it not possible for me to browse through the source 
code.

-San
---------------------------------
