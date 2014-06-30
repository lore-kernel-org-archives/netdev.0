From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 0/2] Misc SCTP updates
Date: Mon, 30 Jun 2014 08:37:04 -0400
Message-ID: <20140630123704.GB15777@hmsreliant.think-freely.org>
References: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48565 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbaF3MhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 08:37:13 -0400
Content-Disposition: inline
In-Reply-To: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 30, 2014 at 01:52:07PM +0200, Daniel Borkmann wrote:
> Daniel Borkmann (2):
>   net: sctp: improve timer slack calculation for transport HBs
>   net: sctp: only warn in proc_sctp_do_alpha_beta if write
> 
>  include/net/sctp/sctp.h | 21 ---------------------
>  net/sctp/sysctl.c       |  5 +++--
>  net/sctp/transport.c    | 17 +++++++++--------
>  3 files changed, 12 insertions(+), 31 deletions(-)
> 
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
