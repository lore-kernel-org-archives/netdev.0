From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: add change MTU support
Date: Thu, 9 Jul 2015 07:57:24 +0200
Message-ID: <20150709055724.GA2270@nanopsycho.orion>
References: <1436396807-62275-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33239 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbbGIF51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 01:57:27 -0400
Received: by wiwl6 with SMTP id l6so7917728wiw.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 22:57:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1436396807-62275-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 09, 2015 at 01:06:47AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Implement ndo_change_mtu: on MTU change, reallocate Rx ring bufs and signal
>HW of new port MTU value.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
