From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: tcp: dont cache unconfirmed intput dst
Date: Thu, 28 Jun 2012 07:13:19 +0200
Message-ID: <1340860399.26242.206.camel@edumazet-glaptop>
References: <20120627.153454.30398632011109264.davem@davemloft.net>
	 <20120627.164418.1928194990434756968.davem@davemloft.net>
	 <20120627.170101.99084491660488389.davem@davemloft.net>
	 <20120627.170830.811332455348620174.davem@davemloft.net>
	 <1340860102.26242.203.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hans.schillstrom@ericsson.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:54143 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab2F1FN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 01:13:26 -0400
Received: by wgbdr13 with SMTP id dr13so1813485wgb.1
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 22:13:24 -0700 (PDT)
In-Reply-To: <1340860102.26242.203.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 07:08 +0200, Eric Dumazet wrote:

> The initial idea was to perform this only for SYN packets received on a
> listener in SYNCOOKIE mode. I'll resend the patch when fully
> implemented, instead of a forward patch.
> 

s/forward/followup/

;)
