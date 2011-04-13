From: Anatolij Gustschin <agust@denx.de>
Subject: Re: [PATCH] mpc5xxx_can: Fix typo causing build failure (of_dev ->
 ofdev)
Date: Wed, 13 Apr 2011 17:13:24 +0200
Message-ID: <20110413171324.45835575@wker>
References: <4DA5B9BF.2010809@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Jeff Mahoney <jeffm@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:53001 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757130Ab1DMPNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 11:13:46 -0400
In-Reply-To: <4DA5B9BF.2010809@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 13 Apr 2011 10:57:03 -0400
Jeff Mahoney <jeffm@suse.com> wrote:

>  The variable is named ofdev, not of_dev.
> 
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> ---
>  drivers/net/can/mscan/mpc5xxx_can.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

There is already a patch pending, [1].

[1] http://patchwork.ozlabs.org/patch/90979/

