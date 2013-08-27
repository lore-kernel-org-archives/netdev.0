From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next v2] net: sctp: sctp_verify_init: clean up
 mandatory checks and add comment
Date: Tue, 27 Aug 2013 10:11:12 -0400
Message-ID: <20130827141112.GC7619@hmsreliant.think-freely.org>
References: <1377612363-10779-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46307 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab3H0OLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 10:11:21 -0400
Content-Disposition: inline
In-Reply-To: <1377612363-10779-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 04:06:03PM +0200, Daniel Borkmann wrote:
> Add a comment related to RFC4960 explaning why we do not check for initial
> TSN, and while at it, remove yoda notation checks and clean up code from
> checks of mandatory conditions. That's probably just really minor, but makes
> reviewing easier.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Thanks Daniel
Acked-by: Neil Horman <nhorman@tuxdriver.com>
