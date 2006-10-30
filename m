From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/5] net: fix uaccess handling
Date: Mon, 30 Oct 2006 15:06:24 -0800 (PST)
Message-ID: <20061030.150624.97264919.davem@davemloft.net>
References: <20061026130010.GA7127@osiris.boeblingen.de.ibm.com>
	<20061026130317.GD7127@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8867
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161371AbWJ3XG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 18:06:29 -0500
To: heiko.carstens@de.ibm.com
In-Reply-To: <20061026130317.GD7127@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Thu, 26 Oct 2006 15:03:17 +0200

> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
>  net/ipv4/raw.c           |   17 +++++++++++------
>  net/ipv6/raw.c           |   17 +++++++++++------
>  net/netlink/af_netlink.c |    5 +++--
>  3 files changed, 25 insertions(+), 14 deletions(-)

Patch applied, thanks.
