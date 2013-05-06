From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -next] netpoll: inverted down_trylock() test
Date: Mon, 6 May 2013 16:00:24 +0300
Message-ID: <20130506130024.GD4686@mwanda>
References: <20130506121513.GA13930@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <amwang@redhat.com>, Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46022 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab3EFNAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 09:00:53 -0400
Content-Disposition: inline
In-Reply-To: <20130506121513.GA13930@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed in mainline actually.  I typed -next by mistake.

regards,
dan carpenter
