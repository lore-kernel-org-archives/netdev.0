From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 12/23] switchdev: cut over to new
 switchdev_port_bridge_setlink
Date: Sat, 9 May 2015 20:49:30 +0200
Message-ID: <20150509184930.GD2290@nanopsycho>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
 <1431193225-807-13-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35721 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbEIStf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 14:49:35 -0400
Received: by wgyo15 with SMTP id o15so97379703wgy.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 11:49:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431193225-807-13-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 09, 2015 at 07:40:14PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Rocker, bonding, and team can now use the switchdev bridge setlink to parse
>raw netlink; no need to duplicate this code in each driver.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
