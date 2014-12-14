From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 1/4] lib: Add netns_switch func for change
 network namespace
Date: Sun, 14 Dec 2014 10:35:49 +0100
Message-ID: <20141214093549.GA2380@nanopsycho.orion>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
 <1418493334-23142-2-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:54732 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaLNJfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 04:35:55 -0500
Received: by mail-wg0-f41.google.com with SMTP id y19so12384702wgg.0
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 01:35:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1418493334-23142-2-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 13, 2014 at 06:55:31PM CET, vadim4j@gmail.com wrote:
>From: Vadim Kochan <vadim4j@gmail.com>
>
>New netns_switch func moved to the lib/namespace.c from ip/ipnetns.c
>so it can be used from the other tools for fast switching
>network namespace.
>
>Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
