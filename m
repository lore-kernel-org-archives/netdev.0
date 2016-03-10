From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/5] vti: Fix recource leeks on pmtu discovery
Date: Thu, 10 Mar 2016 16:53:35 +0300
Message-ID: <56E17C5F.50100@cogentembedded.com>
References: <1457605469-17332-1-git-send-email-steffen.klassert@secunet.com>
 <1457605469-17332-6-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:35489 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbcCJNxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 08:53:49 -0500
Received: by mail-lb0-f179.google.com with SMTP id bc4so112633338lbc.2
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 05:53:48 -0800 (PST)
In-Reply-To: <1457605469-17332-6-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    s/leeks/leaks/.
