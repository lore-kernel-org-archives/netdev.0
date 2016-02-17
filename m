From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 5/8] net: tc: helper functions to query
 action types
Date: Wed, 17 Feb 2016 08:03:30 +0100
Message-ID: <20160217070330.GE2213@nanopsycho.orion>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051803.17139.39151.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36215 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756418AbcBQHDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 02:03:32 -0500
Received: by mail-wm0-f50.google.com with SMTP id g62so143800731wme.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 23:03:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160217051803.17139.39151.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 17, 2016 at 06:18:03AM CET, john.fastabend@gmail.com wrote:
>This is a helper function drivers can use to learn if the
>action type is a drop action.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
