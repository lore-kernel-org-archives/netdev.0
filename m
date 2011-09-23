From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [patch v2] caif: add error handling for allocation
Date: Fri, 23 Sep 2011 12:38:45 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C105791D2BC1882D@EXDCVYMBSTM005.EQ1STM.local>
References: <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
 <20110921072159.GJ4999@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:37902 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753101Ab1IWKi6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 06:38:58 -0400
In-Reply-To: <20110921072159.GJ4999@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Dan]:=20
> The allocation of "phyinfo" wasn't checked, and also the allocation
> wasn't freed on error paths.  Sjur Br=E6ndeland pointed out as well
> that "phy_driver" should be freed on the error path too.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Looks good, thank you Dan.
Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
