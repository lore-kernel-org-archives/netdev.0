From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: qmi_wwan: adding Huawei E367, ZTE MF683
 and Pantech P4200
Date: Fri, 21 Sep 2012 13:22:18 -0400 (EDT)
Message-ID: <20120921.132218.169536453080825317.davem@davemloft.net>
References: <1348085016-30850-1-git-send-email-bjorn@mork.no>
	<1348125485-3404-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	fangxiaozhi@huawei.com, tschaefer@t-online.de, dcbw@redhat.com,
	shawn7400@gmail.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756614Ab2IURWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:22:20 -0400
In-Reply-To: <1348125485-3404-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 20 Sep 2012 09:18:05 +0200

> This is the net-next version of the previously posted patch with the
> same title.  I totally forgot that I had messed with the .driver_info
> fields, making it impossible to apply the same patch to both net and=20
> net-next.
>=20
> Sorry about that.  Please apply this version to net-next.  The other
> one should still be applied to net (if still possible) and stable.

Ok I applied this to net-next, and it should help with the merge
resolution between net and net-next, which BTW Stephen Rothwell
already had to deal with.
