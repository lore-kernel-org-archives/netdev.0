From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] Phonet: advise against enabling the pipe controller
Date: Fri, 08 Oct 2010 14:17:30 -0700 (PDT)
Message-ID: <20101008.141730.258104062.davem@davemloft.net>
References: <1286546523-3340-1-git-send-email-remi@remlab.net>
	<1286546523-3340-2-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41174
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932797Ab0JHVRI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 17:17:08 -0400
In-Reply-To: <1286546523-3340-2-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Fri,  8 Oct 2010 17:02:01 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> As it currently is, the new code path is not compatible with existing
> Nokia modems. This would break existing userspace for Nokia modem, su=
ch
> as the existing oFono ISI driver.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

This really needs to be designed such that it can co-exist with current
userland technology.

Applied.
