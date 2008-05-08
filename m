From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] Hold RTNL while calling dev_close()
Date: Thu, 08 May 2008 02:54:14 -0700 (PDT)
Message-ID: <20080508.025414.182489217.davem@davemloft.net>
References: <20080506182654.GF2217@solarflare.com>
	<20080506184147.GJ2217@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-x25-owner@vger.kernel.org>
In-Reply-To: <20080506184147.GJ2217@solarflare.com>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 6 May 2008 19:41:48 +0100

> dev_close() must be called holding the RTNL.  Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Acked-by: David S. Miller <davem@davemloft.net>

Jeff, please grab this one too.

Thanks.
