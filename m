From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Fix logic breakage due to DSACK separation
Date: Fri, 15 Jun 2007 16:31:28 -0700 (PDT)
Message-ID: <20070615.163128.32622610.davem@davemloft.net>
References: <Pine.LNX.4.64.0706151606220.15358@kivilampi-30.cs.helsinki.fi>
	<20070615.151439.70217492.davem@davemloft.net>
	<Pine.LNX.4.64.0706160121180.12770@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759931AbXFOXbK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 19:31:10 -0400
In-Reply-To: <Pine.LNX.4.64.0706160121180.12770@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 16 Jun 2007 02:04:25 +0300 (EEST)

> On Fri, 15 Jun 2007, David Miller wrote:
>=20
> > Patch applied.
>=20
> ...I think it should go to stable as well.

I thought Baruch's DSACK seperation that created this problem didn't
go in until 2.6.22?

