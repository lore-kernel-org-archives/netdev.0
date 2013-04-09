From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/2] netprio_cgroup: remove task_struct parameter from
 sock_update_netprio()
Date: Tue, 9 Apr 2013 09:39:43 -0400
Message-ID: <20130409133943.GB11337@neilslaptop.think-freely.org>
References: <5163AF37.8010605@huawei.com>
 <5163AF43.502@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Li Zefan <lizefan@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5163AF43.502@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 09, 2013 at 02:03:47PM +0800, Li Zefan wrote:
> The callers always pass current to sock_update_netprio().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
