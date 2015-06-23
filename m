From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: dsa: add support for switchdev VLAN objects
Date: Tue, 23 Jun 2015 16:57:40 -0700
Message-ID: <CAE4R7bC80Vgxpk+bQt_vpvO2b9JyjQ2ykcpgW9+=wRFzmp9N3Q@mail.gmail.com>
References: <1435079929-23018-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33857 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009AbbFWX6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 19:58:00 -0400
In-Reply-To: <1435079929-23018-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2015 at 10:18 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> This patch adds the glue between DSA and switchdev operations to add,
> delete and dump SWITCHDEV_OBJ_PORT_VLAN objects.
>
> This is a first step to link the "bridge vlan" command with hardware
> entries for DSA compatible switch chips.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

I'd like to see an example driver implementation for DSA port_vlan_xxx
callbacks to go along with this patch.  But this patch looks good,

Acked-by: Scott Feldman <sfeldma@gmail.com>
