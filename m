From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 2/3] switchdev: fix: pass correct obj size
 when deferring obj add/del
Date: Wed, 21 Oct 2015 19:15:18 +0200
Message-ID: <20151021171518.GG2210@nanopsycho.orion>
References: <1445446821-26147-1-git-send-email-sfeldma@gmail.com>
 <1445446821-26147-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36948 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbbJURPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 13:15:21 -0400
Received: by wicfv8 with SMTP id fv8so85176770wic.0
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 10:15:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445446821-26147-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 21, 2015 at 07:00:20PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Fixes: 4d429c5dd ("switchdev: introduce possibility to defer obj_add/del")
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Looks fine now, thanks Scott!

Acked-by: Jiri Pirko <jiri@mellanox.com>
