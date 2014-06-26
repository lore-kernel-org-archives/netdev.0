From: David Miller <davem@davemloft.net>
Subject: Re: [trivial PATCH net-next] mac_pton: Use bool not int return
Date: Wed, 25 Jun 2014 17:46:11 -0700 (PDT)
Message-ID: <20140625.174611.1727406746612107344.davem@davemloft.net>
References: <1403634048.29061.23.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403634048.29061.23.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 24 Jun 2014 11:20:48 -0700

> Use bool instead of int as the return type.
> 
> All uses are tested with !.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
