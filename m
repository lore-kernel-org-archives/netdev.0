From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] iov_iter: don't revert iov buffer if csum error
Date: Sun, 30 Apr 2017 22:52:30 -0400 (EDT)
Message-ID: <20170430.225230.1328600416499311759.davem@davemloft.net>
References: <20170429024647.GO29622@ZenIV.linux.org.uk>
        <0cc7c1d2-87d0-6cc4-624b-1cf96678bfd7@huawei.com>
        <20170429204822.GS29622@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, pabeni@redhat.com, edumazet@google.com,
        hannes@stressinduktion.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com,
        weiyongjun1@huawei.com
To: viro@ZenIV.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170429204822.GS29622@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 29 Apr 2017 21:48:23 +0100

> On Sat, Apr 29, 2017 at 05:37:38PM +0800, Ding Tianhong wrote:
> 
>> Looks good, if so, we don't need the csum_error any more,
> 
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> Dave, I could put that through my tree, but I think it would be better off
> in net.git; either way, it needs to go into mainline before -final...

Please just send it directly to Linus, thanks.
