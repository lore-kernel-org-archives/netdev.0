From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hinic: don't build the module by default
Date: Mon, 28 Aug 2017 21:40:07 -0700 (PDT)
Message-ID: <20170828.214007.204759535379129218.davem@davemloft.net>
References: <20170828131605.3173-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aviad.krawczyk@huawei.com,
        linux-kernel@vger.kernel.org
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828131605.3173-1-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Mon, 28 Aug 2017 15:16:05 +0200

> We probably don't want to enable code supporting particular hardware by
> default e.g. when someone does 'make defconfig'. Other ethernet modules
> don't do it.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Applied, thanks.
