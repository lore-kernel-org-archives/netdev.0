From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 4/4] rocker: handle setting bridge ageing_time
Date: Fri, 9 Oct 2015 06:28:40 +0200
Message-ID: <20151009042840.GD2161@nanopsycho.orion>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36782 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757058AbbJIE2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 00:28:43 -0400
Received: by wicgb1 with SMTP id gb1so51171960wic.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 21:28:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444357400-37078-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 09, 2015 at 04:23:20AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>The FDB cleanup timer will get rescheduled to re-evaluate FDB entries
>based on new ageing_time.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
