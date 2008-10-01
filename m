From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] Phonet: Pipe End Point for Phonet Pipes protocol
Date: Wed, 01 Oct 2008 01:41:41 -0700 (PDT)
Message-ID: <20081001.014141.193715047.davem@davemloft.net>
References: <200810011121.14746.remi.denis-courmont@nokia.com>
	<1222849357-8561-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45776
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752007AbYJAIlw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 04:41:52 -0400
In-Reply-To: <1222849357-8561-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed,  1 Oct 2008 11:22:34 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  include/linux/phonet.h   |    4 +-
>  include/net/phonet/pep.h |  115 ++++++-
>  net/phonet/Makefile      |    4 +-
>  net/phonet/af_phonet.c   |    3 +
>  net/phonet/pep.c         |  911 ++++++++++++++++++++++++++++++++++++=
++++++++++
>  net/phonet/socket.c      |    2 +-
>  6 files changed, 1035 insertions(+), 4 deletions(-)
>  create mode 100644 net/phonet/pep.c

include/net/phonet/pep.h doesn't exist in the tree yet, so it's not
possible to apply a patch that makes changes to it yet
