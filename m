From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] qmi_wwan: simplify device matching and add a
 few new devices
Date: Tue, 14 Aug 2012 14:46:53 -0700 (PDT)
Message-ID: <20120814.144653.606253082821782776.davem@davemloft.net>
References: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab2HNVqy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:46:54 -0400
In-Reply-To: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Sun, 12 Aug 2012 21:16:29 +0200

> The home cooked whitelisting code can be removed now that=20
> the USB core supports interface number matching.
>=20
> The second patch adds a few new devices.
>=20
> The third patch improves device list readability by using
> existing macros where possible.
>=20
> I hope this can go in 3.6-rc2/3. The series is based on
> the current net/master (commit 2359a476)

Ok I changed my mind and applied this to 'net'.
