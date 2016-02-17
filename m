From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 3/8] net: sched: add cls_u32 offload hooks
 for netdevs
Date: Wed, 17 Feb 2016 08:02:58 +0100
Message-ID: <20160217070258.GD2213@nanopsycho.orion>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051709.17139.88337.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33568 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756499AbcBQHDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 02:03:00 -0500
Received: by mail-wm0-f43.google.com with SMTP id g62so223503811wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 23:02:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160217051709.17139.88337.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 17, 2016 at 06:17:09AM CET, john.fastabend@gmail.com wrote:
>This patch allows netdev drivers to consume cls_u32 offloads via
>the ndo_setup_tc ndo op.
>
>This works aligns with how network drivers have been doing qdisc
>offloads for mqprio.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
