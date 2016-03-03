From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V2 03/10] net/sched: Macro instead of
 CONFIG_NET_CLS_ACT ifdef
Date: Thu, 3 Mar 2016 15:57:29 +0100
Message-ID: <20160303145729.GD4431@nanopsycho.orion>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
 <1457016960-27832-4-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33834 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbcCCO5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:57:32 -0500
Received: by mail-wm0-f66.google.com with SMTP id p65so4521070wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 06:57:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457016960-27832-4-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 03, 2016 at 03:55:53PM CET, amir@vadai.me wrote:
>Introduce the macros tc_no_actions and tc_for_each_action to make code
>clearer.
>
>Suggested-by: Jiri Pirko <jiri@mellanox.com>
>Signed-off-by: Amir Vadai <amir@vadai.me>

Acked-by: Jiri Pirko <jiri@mellanox.com>
