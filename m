From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/3] net: dsa: refine netdev event notifier
Date: Sun, 13 Mar 2016 21:57:04 +0100
Message-ID: <20160313205704.GD2274@nanopsycho.orion>
References: <1457900494-10266-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1457900494-10266-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35500 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932877AbcCMU5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 16:57:07 -0400
Received: by mail-wm0-f65.google.com with SMTP id n205so11916942wmf.2
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 13:57:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1457900494-10266-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 13, 2016 at 09:21:34PM CET, vivien.didelot@savoirfairelinux.com wrote:
>Rework the netdev event handler, similar to what the Mellanox Spectrum
>driver does, to easily welcome more events later (for example
>NETDEV_PRECHANGEUPPER) and use netdev helpers (such as
>netif_is_bridge_master).
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
