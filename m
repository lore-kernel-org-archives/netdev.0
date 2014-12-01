From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 0/3] timestamping updates
Date: Mon, 1 Dec 2014 09:49:17 +0100
Message-ID: <20141201084917.GA4778@localhost.localdomain>
References: <1417404155-28607-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, luto@amacapital.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:46451 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbaLAItW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 03:49:22 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so23789275wiv.0
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 00:49:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1417404155-28607-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 30, 2014 at 10:22:32PM -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> The main goal for this patchset is to allow correlating timestamps
> with the egress interface. Also introduce a warning, as discussed
> previously, and update the tests to verify the new feature.
> 
> Willem de Bruijn (3):
>   ipv4: warn once on passing AF_INET6 socket to ip_recv_error
>   net-timestamp: allow reading recv cmsg on errqueue with origin tstamp
>   net-timestamp: expand documentation and test

Acked-by: Richard Cochran <richardcochran@gmail.com>
