From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: 2.6.33-rc2: Reported regressions 2.6.31 -> 2.6.32
Date: Wed, 30 Dec 2009 10:58:07 -0600
Message-ID: <4B3B869F.8090003@lwfinger.net>
References: <oBElxfTZdhL.A.bx.-vhOLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <oBElxfTZdhL.A.bx.-vhOLB@chimera>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/29/2009 09:26 AM, Rafael J. Wysocki wrote:
> [NOTES:
>  * I really hope that at least _some_ of the bugs below have been alr=
eady
>    fixed, but I didn't have the time to search through all of the his=
tories.
>    _Please_ let me know which of them can be closed.
>  * If you close one of the bugs in this list, please do your best to =
put the
>    hash of the fix commit into the Bugzilla entry.]
>=20
> This message contains a list of some regressions introduced between 2=
=2E6.31 and
> 2.6.32, for which there are no fixes in the mainline I know of.  If a=
ny of them
> have been fixed already, please let me know.


> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14743
> Subject		: New rtl8187 rfkill support prevents using wlan completely.
> Submitter	: Antti Kaijanm=C3=A4ki <antti@kaijanmaki.net>
> Date		: 2009-12-05 20:10 (25 days old)


This bug is fixed in mainline with commit
70d57139f932b9ca21026253d02af71cf53d764a. This patch has also been back=
ported to
2.6.32.2. The status of the Bugzilla entry has been changed to "CLOSED =
with CODE
=46IX".

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
