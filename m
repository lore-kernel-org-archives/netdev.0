From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Tue, 30 Jul 2013 20:57:21 -0700
Message-ID: <1375243041.10515.66.camel@edumazet-glaptop>
References: <1375238905-6423-1-git-send-email-amwang@redhat.com>
	 <1375240090.10515.53.camel@edumazet-glaptop> <1375240402.22980.5.camel@cr0>
	 <1375241072.10515.59.camel@edumazet-glaptop> <1375241828.22980.6.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:40710 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab3GaD5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 23:57:24 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so250955pbc.22
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 20:57:23 -0700 (PDT)
In-Reply-To: <1375241828.22980.6.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 11:37 +0800, Cong Wang wrote:

> So, you mean this patch only makes sense after my union inet_addr? If
> so, I will merge it into my inet_addr patch.

What about removing the noise from changelog, and give us the true
story ?
