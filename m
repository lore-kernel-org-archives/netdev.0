From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth: use correct thread number for 10/100Mbps link
Date: Mon, 17 Mar 2008 08:13:41 -0400
Message-ID: <47DE6075.3030907@garzik.org>
References: <1204800526-11670-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52414 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138AbYCQMNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:13:45 -0400
In-Reply-To: <1204800526-11670-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Yang wrote:
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> 
> Use thread number of 1 for 10/100Mbps link instead of 4.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
>  drivers/net/ucc_geth.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)

applied


