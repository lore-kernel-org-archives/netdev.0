From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH net-next 0/3] net: dsa: finer bridging control
Date: Sun, 13 Mar 2016 01:49:05 -0500
Message-ID: <87pouyoota.fsf@ketchup.mtl.sfl>
References: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34539 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbcCMGtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 01:49:09 -0500
In-Reply-To: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> This patchset renames the bridging routines of the DSA layer, make the
> unbridging routine return void, and rework the DSA netdev notifier handler,
> similar to what the Mellanox Spectrum driver does.

This is not an RFC, but a normal patchset. I badly reused a previous
git-format-patch command. Please let me know if I need to resend.

Thank you,
Vivien
