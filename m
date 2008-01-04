From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/3] [TCP]: cleanup tcp_parse_options deep
 indented switch
Date: Thu, 03 Jan 2008 20:37:16 -0800 (PST)
Message-ID: <20080103.203716.86605662.davem@davemloft.net>
References: <11993580071900-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53288
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752104AbYADEhR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 23:37:17 -0500
In-Reply-To: <11993580071900-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu,  3 Jan 2008 13:00:05 +0200

> Removed case indentation level & combined some nested ifs, mostly
> within 80 lines now. This is a leftover from indent patch, it
> just had to be done manually to avoid messing it up completely.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
