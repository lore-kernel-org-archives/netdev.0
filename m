From: Andreas Schwab <schwab@suse.de>
Subject: Re: Bad UDP checksum with 82540EM
Date: Sat, 07 Feb 2004 23:42:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <je3c9mv7ea.fsf@sykes.suse.de>
References: <OFE5352D34.67E10D98-ON87256E33.00725857-86256E33.0076C481@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: cramerj@intel.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon D Mason <jonmason@us.ibm.com>
In-Reply-To: <OFE5352D34.67E10D98-ON87256E33.00725857-86256E33.0076C481@us.ibm.com> (Jon
 D. Mason's message of "Sat, 7 Feb 2004 15:37:16 -0600")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason <jonmason@us.ibm.com> writes:

> This probably isn't helpful, but it sounds like a hardware error.  Is t=
he=20
> error occurring on multiple/all HP adapters, or only one?=20

I've also seen it with a HP branded BCM5701 on IA64, but also with a
Broadcom BCM5702 on AMD64 (both using the tg3 driver).  It seems like
broken UDP checksumming is rather common. :-(

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
