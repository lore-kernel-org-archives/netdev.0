From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] usbnet: Set parent device early for
 netdev_printk()
Date: Fri, 02 Jul 2010 21:49:47 -0700 (PDT)
Message-ID: <20100702.214947.184435911.davem@davemloft.net>
References: <1278110361.4878.73.camel@localhost>
	<1278110450.4878.75.camel@localhost>
	<1278111386.4878.77.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pitxyoki@gmail.com, joe@perches.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57799
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751002Ab0GCEtd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jul 2010 00:49:33 -0400
In-Reply-To: <1278111386.4878.77.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 02 Jul 2010 23:56:26 +0100

> On Fri, 2010-07-02 at 23:40 +0100, Ben Hutchings wrote:
>> netdev_printk() follows the net_device's parent device pointer, so
>> we must set that earlier than we previously did.
>>=20
>> Reported-by: Lu=EDs Picciochi Oliveira <pitxyoki@gmail.com>
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> [...]
>=20
> This should also go into a stable update for 2.6.34.


Ok, queued up.
