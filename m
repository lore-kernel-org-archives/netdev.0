From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: RE: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Thu, 16 Sep 2004 17:53:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005001c49c50$c06b9810$a010100a@S2IOtech.com>
References: <414A3213.9030401@pobox.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <414A3213.9030401@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,
We tried it out with 2.6.7. Can you pls specify the kernel version
on which you tried and we will send a patch which works for that version.
We will also send a more detailed description of the changes along with
that.

Thanks,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Thursday, September 16, 2004 5:39 PM
To: ravinandan.arakali@s2io.com
Cc: netdev@oss.sgi.com; leonid.grossman@s2io.com;
raghavendra.koushik@s2io.com; rapuru.sriram@s2io.com
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel


Ravinandan Arakali wrote:
> Hi Jeff,
> Attached is the patch with the first round comments incorporated.
> In addition, this patch contains
> Some fixes related to 32-bit systems.
> Few fixes related to Rx path in NAPI.

hmmm...  it's a big undescribed patch that doesn't apply anymore :/


drivers/net/Kconfig 1.91 -> 1.92: 2657 lines
1 out of 1 hunk FAILED -- saving rejects to file drivers/net/Kconfig.rej
drivers/net/s2io-regs.h 1.1 -> 1.2: 775 lines
drivers/net/s2io.c 1.6 -> 1.7: 4393 lines
1 out of 148 hunks FAILED -- saving rejects to file drivers/net/s2io.c.rej
drivers/net/s2io.h 1.5 -> 1.6: 854 lines


Can you please split it up into individual changes, or at least smaller
chunks?

	Jeff
