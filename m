From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Documentation/networking: update git urls to
 use https over http
Date: Fri, 14 Oct 2016 10:27:55 -0400 (EDT)
Message-ID: <20161014.102755.1254674092225073407.davem@davemloft.net>
References: <20161013150951.4615-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, corbet@lwn.net, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: alexander@alemayhu.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20161013150951.4615-1-alexander@alemayhu.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Alemayhu <alexander@alemayhu.com>
Date: Thu, 13 Oct 2016 17:09:51 +0200

> This fixes the following errors when trying to clone the urls:
> 
> Cloning into 'net'...
> fatal: repository 'http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/' not found
> Cloning into 'net-next'...
> fatal: repository 'http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/' not found
> Cloning into 'linux'...
> fatal: repository 'http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/' not found
> Cloning into 'stable-queue'...
> fatal: repository 'http://git.kernel.org/cgit/linux/kernel/git/stable/stable-queue.git/' not found
> 
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

Since this is simply a documentation fix I applied this to 'net', thanks.
