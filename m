From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: add XFRMA_REPLAY_VAL attribute to SA
 messages
Date: Tue, 4 Nov 2014 12:33:17 +0100
Message-ID: <20141104113316.GB6390@secunet.com>
References: <1414658376-4207-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	dingzhi <zhi.ding@6wind.com>,
	Adrien Mazarguil <adrien.mazarguil@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57321 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbaKDLdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 06:33:25 -0500
Content-Disposition: inline
In-Reply-To: <1414658376-4207-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2014 at 09:39:36AM +0100, Nicolas Dichtel wrote:
> From: dingzhi <zhi.ding@6wind.com>
> 
> After this commit, the attribute XFRMA_REPLAY_VAL is added when no ESN replay
> value is defined. Thus sequence number values are always notified to userspace.
> 
> Signed-off-by: dingzhi <zhi.ding@6wind.com>
> Signed-off-by: Adrien Mazarguil <adrien.mazarguil@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied to ipsec-next, thanks!
