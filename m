From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12.1 1/12] S2io: Code cleanup
Date: Mon, 1 Aug 2005 11:01:50 -0700
Message-ID: <001d01c596c3$17f098c0$4810100a@pc.s2io.com>
References: <42EC5D96.3050304@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@neterion.com>,
        <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>, <raghavendra.koushik@neterion.com>
In-Reply-To: <42EC5D96.3050304@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,
We'll re-verify the patches against latest kernel and resend.

Since the remaining 12 patches are layered on top of the first one,
it will be tough to re-order the patches at this stage. Also, we'll
need to rerun the QA cycle to ensure that nothing got broken in
the process of patch reordering.
We will certainly keep this in mind for our next submission.

Thanks,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Saturday, July 30, 2005 10:12 PM
To: raghavendra.koushik@neterion.com
Cc: netdev@oss.sgi.com; ravinandan.arakali@neterion.com;
leonid.grossman@neterion.com; rapuru.sriram@neterion.com
Subject: Re: [PATCH 2.6.12.1 1/12] S2io: Code cleanup


patch doesn't seem to apply :(

Can you please resend the entire series, taking into account the
comments WRT patch #5?

Also, I was unable to include your fixes in my 'fixes' branch, whose
speed to upstream kernel is accelerated, because patch #1 was not bug fixes.

If you want your bug fixes to go upstream as rapidly as possible, make
sure they are ordered before the code cleanups and new features.  This
allows me to send the fixes upstream immediately, while allowing further
review and testing of the cleanup/feature patches.

	Jeff
