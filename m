From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Re: (no subject)
Date: Sun, 23 Feb 2003 20:18:50 -0800 (PST)
Sender: linux-mips-bounce@linux-mips.org
Message-ID: <32869.4.64.238.61.1046060330.squirrel@www.osdl.org>
References: <20030224040647.611.qmail@webmail17.rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <macro@ds2.pg.gda.pl>, <netdev@oss.sgi.com>,
	<linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
To: <ipv6_san@rediffmail.com>
In-Reply-To: <20030224040647.611.qmail@webmail17.rediffmail.com>
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

>
>
> On Sat, 22 Feb 2003 Maciej W. Rozycki wrote :
>>On 21 Feb 2003, santosh kumar gowda wrote:
>>
>> > Following message is produced at the IAD terminal.....
>> >
>> > # Unable to handle kernel paging request at virtual address
>> > 00000000, epc == 802
>> > 4ce74, ra == 802592a8
>> > Oops in fault.c:do_page_fault, line 172:
>>[...]
>> > Suggestions/Tips are welcome.
>>
>>  Decode the oops first or nobody will be able to give any
>>help.
>
> how do i decode the oops ??? help pls.

Please see linux/REPORTING-BUGS and
linux/Documentation/oops-tracing.txt .
The latter will tell you how to use use 'ksymoops'
to decode an oops message.

~Randy
