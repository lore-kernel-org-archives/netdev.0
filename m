From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/13] Adding a USB CDC MBIM driver
Date: Tue, 23 Oct 2012 02:41:06 -0400 (EDT)
Message-ID: <20121023.024106.530142410573826066.davem@davemloft.net>
References: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	oliver@neukum.org, gregkh@linuxfoundation.org,
	alexey.orishko@gmail.com, gpsuarez2512@gmail.com,
	fangxiaozhi@huawei.com, dcbw@redhat.com, aleksander@lanedo.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab2JWGlI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:41:08 -0400
In-Reply-To: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon, 22 Oct 2012 22:56:27 +0200

> The USB Communications Device Class "Mobile Broadband Interface Model=
"
> (MBIM) is the USB-IFs alternative to the current chipset/vendor
> specific solutions to "Mobile Broadband" device management. The
> specification, including the management protocol description, can be
> downloaded from http://www.usb.org/developers/devclass_docs#approved
>=20
> This driver implementing most MBIM features with the exception of
> 32bit NTB and NDP headers.

All applied to net-next, thanks.
