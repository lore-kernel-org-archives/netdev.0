From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: Wed, 4 Feb 2004 17:14:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002a01c3eb85$6c96dd70$7310100a@S2IOtech.com>
References: <20040205004952.GA27510@cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@suse.de>, <netdev@oss.sgi.com>,
        "'Ragu Vatsavayi'" <raghava.vatsavayi@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Grant Grundler'" <iod00d@hp.com>
In-Reply-To: <20040205004952.GA27510@cup.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Use "u64 phys" and it will always be correct.
> 
> And "char * virt" has the same problem. "char *" will vary
> in size depending arch (ILP32 vs LP64 data model) as well.
> You did claim this code worked on i386, ia64 and PPC64, right?

Yes (Opteron platforms too).
Thanks for the input!
Leonid

> 
> hth,
> grant
> 
