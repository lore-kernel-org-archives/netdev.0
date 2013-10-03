From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net:drivers/net: Miscellaneous conversions to
 ETH_ALEN
Date: Wed, 02 Oct 2013 17:28:34 -0700
Message-ID: <1380760114.2081.81.camel@joe-AO722>
References: <1380679480.2081.24.camel@joe-AO722>
	 <87k3hw469z.fsf@kamboji.qca.qualcomm.com>
	 <1380696054.2081.35.camel@joe-AO722>
	 <CAB=NE6V3b4+B06hzPjhww52wp1FHho3329cP25=5Cy833bysvg@mail.gmail.com>
	 <1380736969.2081.72.camel@joe-AO722>
	 <alpine.DEB.2.02.1310030034030.2162@localhost6.localdomain6>
	 <1380758954.2081.79.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>, ath10k@lists.infradead.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0019.hostedemail.com ([216.40.44.19]:41253 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753216Ab3JCA2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 20:28:38 -0400
In-Reply-To: <1380758954.2081.79.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 17:09 -0700, Joe Perches wrote:
> This has been running a _long_ time (broken?) on
> drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> 
> $ spatch --version
> spatch version 1.0.0-rc14 without Python support and with PCRE support

Nope.  Not hung/broken.  Just a _long_ time to run.

HANDLING: drivers/net/ethernet/mellanox/mlx4/en_rx.c
HANDLING: drivers/net/ethernet/mellanox/mlx4/en_netdev.c
Note: processing took  2299.7s: drivers/net/ethernet/mellanox/mlx4/en_netdev.c
HANDLING: drivers/net/ethernet/mellanox/mlx4/port.c
