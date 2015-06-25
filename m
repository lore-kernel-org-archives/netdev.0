From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH v2 2/4] net: dsa: add support for switchdev VLAN objects
Date: Wed, 24 Jun 2015 18:52:57 -0700
Message-ID: <CAE4R7bB2fGKnqZqQHs7_+awwfgbHPeE3vW=vzRgkEoAwr3C5Dg@mail.gmail.com>
References: <1435171859-27012-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1435171859-27012-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33298 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbbFYBxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 21:53:17 -0400
In-Reply-To: <1435171859-27012-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2015 at 11:50 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> This patch adds the glue between DSA and switchdev operations to add,
> delete and dump SWITCHDEV_OBJ_PORT_VLAN objects.
>
> This is a first step to link the "bridge vlan" command with hardware
> entries for DSA compatible switch chips.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
