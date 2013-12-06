From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] 3c59x/net: Use dev_is_pci() instead of
 hardcoding
Date: Fri, 06 Dec 2013 12:54:02 -0500 (EST)
Message-ID: <20131206.125402.1834036599966030558.davem@davemloft.net>
References: <1386311695-22992-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, guohanjun@huawei.com
To: wangyijing@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386311695-22992-1-git-send-email-wangyijing@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 6 Dec 2013 14:34:55 +0800

> Use PCI standard macro dev_is_pci() instead of hardcoding.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Applied.
