From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 1/12] S2io: cosmetic changes
Date: Thu, 28 Oct 2004 15:01:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003b01c4bd39$becb5a40$9810100a@S2IOtech.com>
References: <41813EEC.5040703@pobox.com>
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
In-reply-to: <41813EEC.5040703@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,
Looks like while copy-pasting the patch from the server into the mail
client, it got messed up.
After following a slightly different procedure of ftp from server,
copy-paste from notepad, it seems to be fine.

Also, the earlier patch2 too seems to apply with some hunks. So, I will 
resend all the 12 patches with this new copy-paste method. Is this okay 
with you ?

Thanks,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Thursday, October 28, 2004 11:48 AM
To: ravinandan.arakali@s2io.com
Cc: 'Francois Romieu'; netdev@oss.sgi.com; leonid.grossman@s2io.com;
raghavendra.koushik@s2io.com; rapuru.sriram@s2io.com;
alicia.pena@s2io.com
Subject: Re: [PATCH 2.6.9-rc2 1/12] S2io: cosmetic changes



OK, patches pass review, but now we have a technical problem.

I started to apply your patches, but only #1 and #2 applied successfully 
with the patch(1) tool.  All the other patches generated rejections.

I have attached my tree, which is

	2.6.8 + patch-2.6.9-rc2 + s2io-2.6.9-rc2.patch

s2io-2.6.9-rc2.patch is attached, which is what I have applied so far 
(your #1 and #2).

Can you please re-diff and re-send patches #3 - #12 ?

Everything else (patch content, email format, etc.) looked great.

Regards,

	Jeff
