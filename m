From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: eliminate bond_close race conditions
Date: Sun, 30 Oct 2011 03:13:45 -0400 (EDT)
Message-ID: <20111030.031345.1770003622707654735.davem@davemloft.net>
References: <4EAA0ADF.5020504@hitachi.com>
	<20111027.231520.698587739433841485.davem@davemloft.net>
	<21320.1319852570@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitsuo.hayasaka.hu@hitachi.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, shemminger@vyatta.com,
	andy@greyhouse.net, linux-kernel@vger.kernel.org,
	yrl.pp-manager.tt@hitachi.com
To: fubar@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21320.1319852570@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 28 Oct 2011 18:42:50 -0700

> 
> 	This patch resolves two sets of race conditions.
 ...
> Tested-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks a lot Jay.
