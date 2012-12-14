From: David Miller <davem@davemloft.net>
Subject: Re: net/usb device additions for -stable
Date: Fri, 14 Dec 2012 18:12:41 -0500 (EST)
Message-ID: <20121214.181241.739657750054924669.davem@davemloft.net>
References: <877gppuu5l.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jspurohit@velocitylimitless.com,
	valdis.kletnieks@vt.edu, jan.ceuleers@computer.org,
	olof.ermis@gmail.com, tommy7765@yahoo.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538Ab2LNXMn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 18:12:43 -0500
In-Reply-To: <877gppuu5l.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Tue, 13 Nov 2012 21:25:58 +0100

> I looked quickly through the list of added devices in the range
> v3.6..net/master and tried to cherry-pick them into the current 3.0,
> 3.2, 3.4 and 3.6 stable trees.  There weren't really that many. The
> result was:
>=20
> # for stable-3.6:
> af1b85e usb/ipheth: Add iPhone 5 support
> c6846ee net: qmi_wwan: adding more ZTE devices
> bbc8d92 net: cdc_ncm: add Huawei devices
>=20
> # for stable-3.4:
> af1b85e usb/ipheth: Add iPhone 5 support
>=20
> # for stable-3.2:
> af1b85e usb/ipheth: Add iPhone 5 support
>=20
> # for stable-3.0:
> af1b85e usb/ipheth: Add iPhone 5 support

The iPhone 5 change applied cleanly in all cases so I added that one.
The others did not.

Could you respin them for me and I'll queue them up for the next batch
I send out?

Thanks.
