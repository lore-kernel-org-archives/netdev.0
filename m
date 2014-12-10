From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] dummy: add support for ethtool get_drvinfo
Date: Tue, 9 Dec 2014 22:44:34 -0200
Message-ID: <20141210004434.GB20722@t520.home>
References: <1417824804-20634-1-git-send-email-fbl@redhat.com>
 <20141209.160726.984535504729715315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbaLJAoi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 19:44:38 -0500
Content-Disposition: inline
In-Reply-To: <20141209.160726.984535504729715315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2014 at 04:07:26PM -0500, David Miller wrote:
> From: Flavio Leitner <fbl@redhat.com>
> Date: Fri,  5 Dec 2014 22:13:24 -0200
> 
> > The command 'ethtool -i' is useful to find details
> > about the interface like the device driver being used.
> > This was missing for dummy driver.
> > 
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> 
> Applied, thank you.
> 
> Consider adding a MODULE_VERSION instance since you've added an
> explicit version.

Done, patch sent:
[net-next] dummy: use MODULE_VERSION

fbl
