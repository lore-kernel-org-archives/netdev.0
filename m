From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 01/11] net: Simplify GRE case in
 flow_dissector
Date: Fri, 22 May 2015 08:36:29 +0200
Message-ID: <20150522063629.GA2138@nanopsycho.orion>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
 <1432253506-3646977-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:36474 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbbEVGgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 02:36:32 -0400
Received: by wgbgq6 with SMTP id gq6so8155854wgb.3
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 23:36:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432253506-3646977-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 22, 2015 at 02:11:36AM CEST, tom@herbertland.com wrote:
>Do break when we see routing flag or a non-zero version number in GRE
>header.
>
>Signed-off-by: Tom Herbert <tom@herbertland.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
