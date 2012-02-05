From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net, decnet: remove unused variable from dn_output()
Date: Sun, 05 Feb 2012 17:46:23 -0500 (EST)
Message-ID: <20120205.174623.402259480734565793.davem@davemloft.net>
References: <alpine.LNX.2.00.1202052327050.32529@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, steffen.klassert@secunet.com,
	gregory.v.rose@intel.com, paul.gortmaker@windriver.com,
	SteveW@ACM.org, emserrat@geocities.com
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1202052327050.32529@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 5 Feb 2012 23:28:57 +0100 (CET)

> The variable 'neigh' is assigned to, but otherwise completely
> unused. So let's remove it.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.
