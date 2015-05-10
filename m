From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v7 16/24] switchdev: cut over to new
 switchdev_port_bridge_dellink
Date: Sun, 10 May 2015 21:58:28 +0200
Message-ID: <20150510195827.GE2022@nanopsycho>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
 <1431276489-64199-17-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:33324 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbEJT6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 15:58:45 -0400
Received: by wgin8 with SMTP id n8so111480162wgi.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 12:58:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431276489-64199-17-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 10, 2015 at 06:48:01PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Rocker, bonding and team and switch over to the new
>switchdev_port_bridge_dellink to avoid duplicating code in each driver.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
