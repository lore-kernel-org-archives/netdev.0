From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH 3/3] net: ipv6: Implement /proc/net/icmp6.
Date: Wed, 29 May 2013 14:47:36 +0900
Message-ID: <1369806459-26901-1-git-send-email-lorenzo@google.com>
References: <ko3rsc@ger.gmane.org>
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:58906 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425Ab3E2Frs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:47:48 -0400
Received: by mail-yh0-f74.google.com with SMTP id t59so553410yho.5
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 22:47:48 -0700 (PDT)
In-Reply-To: <ko3rsc@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, here's a new complete patchset.
