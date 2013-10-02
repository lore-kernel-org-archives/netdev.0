From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5 1/3] flow_dissector: factor out the ports
 extraction in skb_flow_get_ports
Date: Wed, 02 Oct 2013 04:50:51 -0700
Message-ID: <1380714651.19002.89.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380713966-3891-1-git-send-email-nikolay@redhat.com>
	 <1380713966-3891-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com, vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:57921 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab3JBLux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 07:50:53 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so760183pbc.25
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 04:50:53 -0700 (PDT)
In-Reply-To: <1380713966-3891-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 13:39 +0200, Nikolay Aleksandrov wrote:
> Factor out the code that extracts the ports from skb_flow_dissect and
> add a new function skb_flow_get_ports which can be re-used.
> 
> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
