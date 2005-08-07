From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12.1 1/12] S2io: Code cleanup
Date: Sun, 7 Aug 2005 13:51:52 -0700
Message-ID: <000001c59b91$d7f07370$4810100a@pc.s2io.com>
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
The entire set of patches have been resent and an additional
patch13 to address earlier comments.
Pls confirm if these patches apply correctly.

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
