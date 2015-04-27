From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH][net-next] xfrm: slightly optimise xfrm_input
Date: Mon, 27 Apr 2015 12:39:10 +0200
Message-ID: <20150427103908.GM8928@secunet.com>
References: <1429865371-14722-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47791 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932423AbbD0KjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 06:39:16 -0400
Content-Disposition: inline
In-Reply-To: <1429865371-14722-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2015 at 04:49:31PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Check x->km.state with XFRM_STATE_ACQ only when state is not
> XFRM_STAT_VALID, not everytime
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied to ipsec-next, thanks a lot Li!
