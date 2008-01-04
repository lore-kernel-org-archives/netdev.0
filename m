From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/3] [TCP]: Perform setting of common
 control fields in one place
Date: Thu, 03 Jan 2008 20:39:27 -0800 (PST)
Message-ID: <20080103.203927.179004797.davem@davemloft.net>
References: <11993580071900-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11993580071646-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11993580071094-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53295
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753724AbYADEj2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 23:39:28 -0500
In-Reply-To: <11993580071094-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu,  3 Jan 2008 13:00:07 +0200

> In case of segments which are purely for control without any
> data (SYN/ACK/FIN/RST), many fields are set to common values
> in multiple places.
 ...
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

It's nice to see Arnaldo's tools get some usage :-)

Applied, thanks!
