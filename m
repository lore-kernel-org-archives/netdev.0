From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: RE: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Tue, 28 Sep 2004 10:13:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002b01c4a57e$84da0700$a010100a@S2IOtech.com>
References: <41597DA4.5040200@pobox.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <41597DA4.5040200@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff, Randy,
We are sorry about that. We will split the first patch into multiple smaller
patches and resubmit them one-by-one.
We appreciate all your patience.

Regards,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Tuesday, September 28, 2004 8:05 AM
To: ravinandan.arakali@s2io.com
Cc: netdev@oss.sgi.com; leonid.grossman@s2io.com;
raghavendra.koushik@s2io.com; rapuru.sriram@s2io.com
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel


Ravinandan Arakali wrote:
> Hi,
> Attached are the updated patches. It is designed to work on the latest
> kernel. Also, this time the submission is split to 3 patches(they need
> to applied in the order mentioned below).
>
> s2io_styling_level1  - Contains
>                              a. styling related, function name changes.
>                              b. fix for 32-bit systems.
>                              c. modified Transmit descriptor allocation
> strategy.
>                              d. miscellaneous fixes.


When we say "separate logical changes", we mean it :)

This means that your level1 patch should be split into at least 4 patches.

Second, send each patch in a separate email, as described in
http://linux.yyz.us/patch-format.html (and
Documentation/SubmittingPatches) rather than sending as a tarball.

	Jeff
