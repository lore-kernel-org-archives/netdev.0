From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 1/12] S2io: cosmetic changes
Date: Thu, 28 Oct 2004 18:10:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005301c4bd54$26daea00$9810100a@S2IOtech.com>
References: <418181D9.5010603@pobox.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, <netdev@oss.sgi.com>,
        <leonid.grossman@s2io.com>, <raghavendra.koushik@s2io.com>,
        <rapuru.sriram@s2io.com>, <alicia.pena@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-reply-to: <418181D9.5010603@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,
Looks like outlook client is garbling some of the patch.
We'll try to send using different client, but can you pls
try with -l option on all the patches and see if it applies
cleanly ?

Thanks for your patience.

Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Thursday, October 28, 2004 4:34 PM
To: ravinandan.arakali@s2io.com
Cc: 'Francois Romieu'; netdev@oss.sgi.com; leonid.grossman@s2io.com;
raghavendra.koushik@s2io.com; rapuru.sriram@s2io.com;
alicia.pena@s2io.com
Subject: Re: [PATCH 2.6.9-rc2 1/12] S2io: cosmetic changes


With this new resend, I tried with both my automated scripts, and 
applying manually as well.

All attempts succeed on patches #1 and #2, but fail on #3 - #12.

If I manually add the "-l" argument to patch(1), then patch #3 succeeds. 
  That implies that somewhere in your process, whitespace in your 
patches is getting corrupted.

	Jeff
