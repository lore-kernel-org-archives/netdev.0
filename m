From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mrf24j40: separate h/w init and add checkings
Date: Thu, 12 Jun 2014 11:03:24 -0700 (PDT)
Message-ID: <20140612.110324.932062947770396872.davem@davemloft.net>
References: <1402564248-20606-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402564248-20606-1-git-send-email-varkab@cdac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkabhadram@gmail.com>
Date: Thu, 12 Jun 2014 14:40:48 +0530

> separate the mrf24j40 hardware initialisation from probe()
> and adds the sanity checkings.
> 
> These checkings are required if somebody hasn't a right spi configuration 
> the probe function should fail. So we have to return from there.
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

Applied, thanks.
