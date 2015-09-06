From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: bridge: remove unnecessary switchdev include
Date: Sun, 6 Sep 2015 08:32:44 +0200
Message-ID: <20150906063244.GC2141@nanopsycho.orion>
References: <1441504181-20376-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37752 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbbIFGcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 02:32:47 -0400
Received: by wicfx3 with SMTP id fx3so53104379wic.0
        for <netdev@vger.kernel.org>; Sat, 05 Sep 2015 23:32:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1441504181-20376-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Sep 06, 2015 at 03:49:41AM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Remove the unnecessary switchdev.h include from br_netlink.c.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
