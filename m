From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv4] netem: Segment GSO packets on enqueue
Date: Mon, 02 May 2016 09:56:28 -0700
Message-ID: <1462208188.5535.259.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
	 <1462206015-3484-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org, stephen@networkplumber.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34075 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbcEBQ4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:56:31 -0400
Received: by mail-pf0-f174.google.com with SMTP id y69so80810453pfb.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:56:30 -0700 (PDT)
In-Reply-To: <1462206015-3484-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-02 at 12:20 -0400, Neil Horman wrote:
> This was recently reported to me, and reproduced on the latest net kernel,
> when attempting to run netperf from a host that had a netem qdisc attached
> to the egress interface:

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Neil.
