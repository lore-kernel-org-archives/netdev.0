From: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Subject: Re: 3C905C-TX
Date: Wed, 30 Nov 2005 08:18:26 -0500
Message-ID: <Pine.LNX.4.61.0511300813190.18193@chaos.analogic.com>
References: <eab8d9e30511300459j695ed942n@mail.gmail.com>
Reply-To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Linux kernel" <linux-kernel@vger.kernel.org>, <andrewm@uow.edu.au>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <eab8d9e30511300459j695ed942n@mail.gmail.com>
Content-class: urn:content-classes:message
To: =?iso-8859-1?Q?Daniel_H=F6hnle?= <hoehnle.dan@googlemail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 30 Nov 2005, [iso-8859-1] Daniel H=F6hnle wrote:

> Hello i have Suse Linux 9.3 and a 3Com 3C905C-TX Networkcard. But she
> don't works. Where can I get a Driver??? Or give it a Dokumentation
> how I can make the Driver??
>
> Thanks
> Daniel H=F6hnle

The 3c59x driver should work for this device. If it's real
new, you may have to add its ID to the structure at line
3365 in 3x59x.c or contact the maintainer.


Cheers,
Dick Johnson
Penguin : Linux version 2.6.13.4 on an i686 machine (5589.55 BogoMips).
Warning : 98.36% of all statistics are fiction.

****************************************************************
The information transmitted in this message is confidential and may be pr=
ivileged.  Any review, retransmission, dissemination, or other use of thi=
s information by persons or entities other than the intended recipient is=
 prohibited.  If you are not the intended recipient, please notify Analog=
ic Corporation immediately - by replying to this message or by sending an=
 email to DeliveryErrors@analogic.com - and destroy all copies of this in=
formation, including any attachments, without reading or disclosing them.

Thank you.
