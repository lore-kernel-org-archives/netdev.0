From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: can: af_can.c: Fix checkpatch warnings
Date: Mon, 11 Mar 2013 07:40:44 -0400 (EDT)
Message-ID: <20130311.074044.1360965348131709747.davem@davemloft.net>
References: <1362918526-26730-1-git-send-email-valentin.ilie@gmail.com>
	<1362950113-25515-1-git-send-email-valentin.ilie@gmail.com>
	<513D8193.3080405@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: valentin.ilie@gmail.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <513D8193.3080405@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Mon, 11 Mar 2013 08:02:43 +0100

> On 10.03.2013 22:15, Valentin Ilie wrote:
> 
>> Replace printk(KERN_ERR with pr_err
>> Add space before {
>> Removed OOM messages
>> 
>> Signed-off-by: Valentin Ilie <valentin.ilie@gmail.com>
> 
> 
> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, thanks.
