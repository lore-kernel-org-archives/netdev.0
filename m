From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding:delete a dereference before check
Date: Mon, 13 Jun 2011 18:29:56 -0400 (EDT)
Message-ID: <20110613.182956.2297472017294393300.davem@davemloft.net>
References: <20110611081214.GA21427@shale.localdomain>
	<1307975410-13523-1-git-send-email-panweiping3@gmail.com>
	<18226.1308003061@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panweiping3@gmail.com, error27@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <18226.1308003061@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 13 Jun 2011 15:11:01 -0700

> Weiping Pan <panweiping3@gmail.com> wrote:
> 
>>Dan Carpenter found that there was a dereference before a check,
>>added in 56d00c677de0(bonding:delete lacp_fast from ad_bond_info).
>>
>>Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks.
