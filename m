From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] rocker: call correct unregister function on error
Date: Tue, 23 Jun 2015 10:01:40 +0200
Message-ID: <20150623080140.GA2303@nanopsycho.ki.iif.hu>
References: <1435045930-12130-1-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	Gilad Ben-Yossef <giladb@ezchip.com>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:35475 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbbFWIBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 04:01:48 -0400
Received: by wgbhy7 with SMTP id hy7so2180823wgb.2
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 01:01:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1435045930-12130-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 23, 2015 at 09:52:10AM CEST, gilad@benyossef.com wrote:
>Use the correct unregister function matching the register
>function on the error path.
>
>Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
>CC: Gilad Ben-Yossef <giladb@ezchip.com>
>CC: Scott Feldman <sfeldma@gmail.com>
>CC: Jiri Pirko <jiri@resnulli.us>

Fixes: c1beeef7a32a791a ("rocker: implement IPv4 fib offloading")
Acked-by: Jiri Pirko <jiri@resnulli.us>
