From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/3] switchdev: split switchdev_attr into
 individual structs
Date: Wed, 21 Oct 2015 09:49:17 +0200
Message-ID: <20151021074917.GD2210@nanopsycho.orion>
References: <1445369799-2345-1-git-send-email-sfeldma@gmail.com>
 <1445369799-2345-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38123 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbJUHtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 03:49:20 -0400
Received: by wicll6 with SMTP id ll6so61439123wic.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 00:49:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445369799-2345-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 20, 2015 at 09:36:39PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>This was already done for switchdev_objs.   Changing switchdev_attrs to new
>style makes switchdev API consistent for both attrs and objs.
>
>No functional changes here.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

This was on my todo list. Thanks for taking care of this.

Acked-by: Jiri Pirko <jiri@mellanox.com>
