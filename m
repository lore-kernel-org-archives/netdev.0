From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH] [IPv6]: Treat ND option 31 as userland (DNSSL support)
Date: Thu, 3 May 2012 13:51:56 -0700
Message-ID: <CA+HUmGiaMrgpz4zV7MR0uO4YETECWLGXd_TOW4BFP33aMGA=nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:56734 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004Ab2ECUv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 16:51:57 -0400
Received: by yenm10 with SMTP id m10so1708511yen.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 13:51:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does anybody know if this patch should be in v3.4? I did not see it in 3.4-rc5.
Thanks,
Francesco Ruggeri


Date:	Thu, 12 Apr 2012 15:57:51 -0400 (EDT)
From:	David Miller <davem@...emloft.net>
To:	raorn@...rn.name
Cc:	netdev@...r.kernel.org
Subject: Re: [PATCH] [IPv6]: Treat ND option 31 as userland (DNSSL support)

From: "Alexey I. Froloff" <raorn@...rn.name>
Date: Fri,  6 Apr 2012 19:50:58 +0400

> As specified in RFC6106, DNSSL option contains one or more domain names
> of DNS suffixes.  8-bit identifier of the DNSSL option type as assigned
> by the IANA is 31.  This option should also be treated as userland.
>
> Signed-off-by: Alexey I. Froloff <raorn@...rn.name>

Applied to net-next, thanks.
