From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] rocker: fix error return code in rocker_probe()
Date: Thu, 16 Apr 2015 14:47:15 +0200
Message-ID: <20150416124715.GB1965@nanopsycho.orion>
References: <1429186862-20989-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36483 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757151AbbDPMrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 08:47:19 -0400
Received: by wizk4 with SMTP id k4so193310774wiz.1
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 05:47:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1429186862-20989-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 16, 2015 at 02:21:02PM CEST, weiyj_lk@163.com wrote:
>From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
>Fix to return -EINVAL from the invalid PCI region size error
>handling case instead of 0, as done elsewhere in this function.
>
>Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>


Good catch.

Acked-by: Jiri Pirko <jiri@resnulli.us>
