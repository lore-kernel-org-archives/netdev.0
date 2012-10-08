From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3] iproute2: add support for tcp_metrics
Date: Mon, 8 Oct 2012 10:26:37 -0700
Message-ID: <20121008102637.4ab1f834@nehalam.linuxnetplumber.net>
References: <1349302059-3283-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32798 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753051Ab2JHR1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 13:27:18 -0400
In-Reply-To: <1349302059-3283-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Oct 2012 01:07:39 +0300
Julian Anastasov <ja@ssi.bg> wrote:

> 	ip tcp_metrics/tcpmetrics
> 
> 	We support get/del for single entry and dump for
> show/flush.
> 
> v3:
>  - fix rtt/rttvar shifts as suggested by Eric Dumazet
>  - show rtt/rttvar usecs as suggested by David Laight
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied. Thanks
