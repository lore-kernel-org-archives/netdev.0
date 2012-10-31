From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 2] net/ipv4/ipconfig: add device address to a
 KERN_INFO message
Date: Wed, 31 Oct 2012 13:23:20 -0400 (EDT)
Message-ID: <20121031.132320.161133126258025586.davem@davemloft.net>
References: <50891F5F.7060003@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Claudio.Fontana@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50891F5F.7060003@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Claudio Fontana <Claudio.Fontana@huawei.com>
Date: Thu, 25 Oct 2012 13:15:43 +0200

> adds a "hwaddr" to the "IP-Config: Complete" KERN_INFO message
> with the dev_addr of the device selected for auto configuration.
> 
> Signed-off-by: Claudio Fontana <claudio.fontana@huawei.com>

Applied to net-next
