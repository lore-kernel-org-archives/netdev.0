From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] net/mlx4_en: Split SW RX dropped counter per RX
 ring
Date: Wed, 20 Apr 2016 18:02:30 -0700
Message-ID: <1461200550.7627.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
	 <1461157278-18528-5-git-send-email-ogerlitz@mellanox.com>
	 <1461164209.10638.262.camel@edumazet-glaptop3.roam.corp.google.com>
	 <571799A3.402@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34566 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbcDUBCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 21:02:32 -0400
Received: by mail-pf0-f181.google.com with SMTP id y69so7291055pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 18:02:32 -0700 (PDT)
In-Reply-To: <571799A3.402@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-20 at 18:00 +0300, Or Gerlitz wrote:

> Just to be sure, you'd like me to re-spin this and fix the reporter name?

Absolutely not, I believe patchwork should handle this just fine.

Patchwork does not understand the "Fixes:" tag yet, but Reported-by: is
fine.
