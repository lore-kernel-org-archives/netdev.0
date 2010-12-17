From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] tehuti: Firmware filename is tehuti/bdx.bin
Date: Fri, 17 Dec 2010 10:16:36 -0800 (PST)
Message-ID: <20101217.101636.104051313.davem@davemloft.net>
References: <1292595184.3136.843.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe.jin@oracle.com, baum@tehutinetworks.net, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	guru.anbalagane@oracle.com, greg.marsden@oracle.com,
	zhenzhong.duan@oracle.com, jaswinder@infradead.org
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292595184.3136.843.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 17 Dec 2010 14:13:03 +0000

> My conversion of tehuti to use request_firmware() was confused about
> the filename of the firmware blob.  Change the driver to match the
> blob.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied and queued up for -stable, thanks.
