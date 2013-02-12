From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next v2] net: sctp: remove unused multiple cookie keys
Date: Tue, 12 Feb 2013 10:20:42 -0500
Message-ID: <20130212152042.GB7849@hmsreliant.think-freely.org>
References: <1360682133-17658-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46278 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758473Ab3BLPUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 10:20:53 -0500
Content-Disposition: inline
In-Reply-To: <1360682133-17658-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2013 at 04:15:33PM +0100, Daniel Borkmann wrote:
> Vlad says: The whole multiple cookie keys code is completely unused
> and has been all this time. Noone uses anything other then the
> secret_key[0] since there is no changeover support anywhere.
> 
> Thus, for now clean up its left-over fragments.
> 
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
