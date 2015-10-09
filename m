From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 1/4] switchdev: add bridge ageing_time
 attribute
Date: Fri, 9 Oct 2015 06:27:41 +0200
Message-ID: <20151009042741.GA2161@nanopsycho.orion>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34184 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbbJIE1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 00:27:44 -0400
Received: by wicfx3 with SMTP id fx3so53766163wic.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 21:27:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444357400-37078-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 09, 2015 at 04:23:17AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Setting the stage to push bridge-level attributes down to port driver so
>hardware can be programmed accordingly.  Bridge-level attribute example is
>ageing_time.  This is a per-bridge attribute, not a per-bridge-port attr.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
