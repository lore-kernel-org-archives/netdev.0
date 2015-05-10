From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v7 15/24] switchdev: add new
 switchdev_port_bridge_dellink
Date: Sun, 10 May 2015 21:58:08 +0200
Message-ID: <20150510195808.GD2022@nanopsycho>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
 <1431276489-64199-16-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35357 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbEJT6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 15:58:14 -0400
Received: by widdi4 with SMTP id di4so82969879wid.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 12:58:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431276489-64199-16-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 10, 2015 at 06:48:00PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Same change as setlink.  Provide the wrapper op for SELF ndo_bridge_dellink
>and call into the switchdev driver to delete afspec VLANs.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
