From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH][net-next] xfrm: remove the unnecessary checking before
 call xfrm_pol_hold
Date: Tue, 5 May 2015 13:40:52 +0200
Message-ID: <20150505114052.GP8928@secunet.com>
References: <1430385221-21847-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37133 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758466AbbEELk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 07:40:57 -0400
Content-Disposition: inline
In-Reply-To: <1430385221-21847-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 05:13:41PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> xfrm_pol_hold will check its input with NULL
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied to ipsec-next, thanks!
