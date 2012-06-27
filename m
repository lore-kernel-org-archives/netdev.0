From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: qmi_wwan: simplify a check in qmi_wwan_bind()
Date: Tue, 26 Jun 2012 17:13:36 -0700 (PDT)
Message-ID: <20120626.171336.1112981494948391973.davem@davemloft.net>
References: <20120626083945.GA8946@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bjorn@mork.no
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab2F0ANj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 20:13:39 -0400
In-Reply-To: <20120626083945.GA8946@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 26 Jun 2012 11:39:45 +0300

> This code is easier to read if we specify which flags we want at the
> condition instead of at the top of the function.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> Acked-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks.
