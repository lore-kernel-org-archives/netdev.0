From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC 17/42] drivers/net/ethernet/renesas: don't check resource
 with devm_ioremap_resource
Date: Fri, 10 May 2013 15:07:45 +0400
Message-ID: <518CD501.1040909@cogentembedded.com>
References: <1368173847-5661-1-git-send-email-wsa@the-dreams.de> <1368173847-5661-18-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:45887 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032Ab3EJLHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 07:07:41 -0400
Received: by mail-la0-f45.google.com with SMTP id fp12so3867976lab.32
        for <netdev@vger.kernel.org>; Fri, 10 May 2013 04:07:39 -0700 (PDT)
In-Reply-To: <1368173847-5661-18-git-send-email-wsa@the-dreams.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10-05-2013 12:17, Wolfram Sang wrote:

> devm_ioremap_resource does sanity checks on the given resource. No need to
> duplicate this in the driver.

> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

WBR, Sergei
