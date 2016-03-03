From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V1 04/10] net/act_skbedit: Utility functions for
 mark action
Date: Thu, 3 Mar 2016 10:40:43 +0100
Message-ID: <20160303094043.GD2105@nanopsycho.orion>
References: <1456997006-18538-1-git-send-email-amir@vadai.me>
 <1456997006-18538-5-git-send-email-amir@vadai.me>
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
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35283 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732AbcCCJku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 04:40:50 -0500
Received: by mail-wm0-f67.google.com with SMTP id 1so3108754wmg.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 01:40:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456997006-18538-5-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 03, 2016 at 10:23:20AM CET, amir@vadai.me wrote:
>Enable device drivers to query the action if is a mark action and what
>value to use for marking.
>
>Signed-off-by: Amir Vadai <amir@vadai.me>

Acked-by: Jiri Pirko <jiri@mellanox.com>
