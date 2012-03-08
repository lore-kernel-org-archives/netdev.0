From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver
 support
Date: Thu, 08 Mar 2012 13:43:38 -0800 (PST)
Message-ID: <20120308.134338.1946356302291460775.davem@davemloft.net>
References: <20120306143559.GB23314@kroah.com>
	<87r4x5u478.fsf@nemi.mork.no>
	<20120308185324.GA13836@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, linux-usb@vger.kernel.org, dcbw@redhat.com,
	oliver@neukum.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757593Ab2CHVow convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 16:44:52 -0500
In-Reply-To: <20120308185324.GA13836@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 8 Mar 2012 10:53:24 -0800

> On Tue, Mar 06, 2012 at 04:41:47PM +0100, Bj=F8rn Mork wrote:
>> I've managed to make them dependent on not-yet-merged patches in
>> net-next as well (the initial addition of the qmi_wwan driver), so I
>> believe that will be equally difficult.  Bad planning from my side I
>> guess...
>=20
> I can take those patches as well if needed, to help unwind the
> dependancy mess, and the network maintainer doesn't mind.

I don't mind :)
