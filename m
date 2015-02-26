From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/3] rocker: rename lport to pport
Date: Thu, 26 Feb 2015 07:55:25 +0100
Message-ID: <20150226065525.GC2074@nanopsycho.orion>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
 <1424924138-15928-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:37655 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbbBZGz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 01:55:29 -0500
Received: by wghk14 with SMTP id k14so8147981wgh.4
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 22:55:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1424924138-15928-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 26, 2015 at 05:15:37AM CET, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>This is just a rename of physical ports from "lport" to "pport".  Not a
>functional change.  OF-DPA uses logical ports (lport) for tunnels, but the
>driver (and device) were using "lport" for physical ports.  Renaming physical
>ports references to "pport", freeing up "lport" for use later with tunnels.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
