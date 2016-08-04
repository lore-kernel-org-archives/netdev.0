From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v3 0/3] sctp_diag: A bunch of fixes for upcoming 'ss'
 support
Date: Thu, 4 Aug 2016 09:36:17 -0300
Message-ID: <20160804123617.GG2967@localhost.localdomain>
References: <1470305517-31880-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933388AbcHDMgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 08:36:22 -0400
Content-Disposition: inline
In-Reply-To: <1470305517-31880-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 04, 2016 at 12:11:54PM +0200, Phil Sutter wrote:
> The following series contains a number of fixes necessary to make my yet
> unpublished 'ss' support patch functional.
> 
> Changes since v1:
> - Fixed patch 2/3
> - Rebased whole series onto current net-next/master
> 
> Changes since v2:
> - Improved description of patch 2/3
> 
> Phil Sutter (3):
>   sctp: Export struct sctp_info to userspace
>   sctp_diag: Fix T3_rtx timer export
>   sctp_diag: Respect ss adding TCPF_CLOSE to idiag_states
> 

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Thanks!
