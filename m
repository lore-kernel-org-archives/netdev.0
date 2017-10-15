From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,0/3] Add init of send table and var renames
Date: Sat, 14 Oct 2017 18:43:10 -0700 (PDT)
Message-ID: <20171014.184310.1151587743577615370.davem@davemloft.net>
References: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Fri, 13 Oct 2017 12:28:02 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> Add initialization of send indirection table. Otherwise it may contain
> old info of previous device with different number of channels.
> 
> Also, did some variable renaming for easier reading.

Series applied, thank you.
