From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp: probe: allow more advanced ingress
 filtering by mark
Date: Fri, 30 Aug 2013 07:36:30 -0400
Message-ID: <20130830113630.GB1142@hmsreliant.think-freely.org>
References: <1377795289-1914-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60517 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882Ab3H3Lgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 07:36:36 -0400
Content-Disposition: inline
In-Reply-To: <1377795289-1914-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 29, 2013 at 06:54:49PM +0200, Daniel Borkmann wrote:
> This is a follow-up commit for commit b1dcdc68b1f4 ("net: tcp_probe:
> allow more advanced ingress filtering by mark") that allows for
> advanced SCTP probe module filtering based on skb mark (for a more
> detailed description and advantages using mark, refer to b1dcdc68b1f4).
> The current option to filter by a given port is still being preserved.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
