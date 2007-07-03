From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: [PATCH] ucc_geth.c, make PHY device optional.
Date: Tue, 3 Jul 2007 02:52:13 +0200
Message-ID: <012701c7bd0c$64fe67c0$0e67a8c0@Jocke>
References: <1183142980.20673.89.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'linuxppc-dev Development'" <linuxppc-dev@ozlabs.org>,
	"'Netdev'" <netdev@vger.kernel.org>,
	"'Li Yang-r58472'" <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:10896 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755629AbXGCAwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 20:52:19 -0400
In-Reply-To: <1183142980.20673.89.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This patch makes the PHY optional for ucc_geth.c ethernet driver.
> This is useful to support a direct mii to mii connection to, for example,
> a onboard swicth.
> 
> Signed-off-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
----
[SNIP patch sent last Friday]

Since this is my last week before vacation, I would really like to
get feedback on this patch sooner than later :)

 Jocke

