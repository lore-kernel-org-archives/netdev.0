From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ip_gre: Add IPPROTO_GRE to flowi in ipgre_tunnel_xmit
Date: Fri, 11 Feb 2011 18:44:55 +0800
Message-ID: <AANLkTi=AZny3AprR1MnOnnyCu6aemauQTPzL6psNtfoZ@mail.gmail.com>
References: <20110211093040.GB29583@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65199 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848Ab1BKKpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:45:16 -0500
Received: by fxm20 with SMTP id 20so2532882fxm.19
        for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 02:45:15 -0800 (PST)
In-Reply-To: <20110211093040.GB29583@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 11, 2011 at 5:30 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> Commit 5811662b15db018c740c57d037523683fd3e6123 accidentally
> removed the setting of IPPROTO_GRE from the struct flowi
> in ipgre_tunnel_xmit. This patch restores it.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
Acked-by: Changli Gao <xiaosuo@gmail.com>

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
