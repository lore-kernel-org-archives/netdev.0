From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: use setup_timer
Date: Sun, 12 Mar 2017 23:47:58 -0700 (PDT)
Message-ID: <20170312.234758.810070491418409907.davem@davemloft.net>
References: <3afa5498142ef68256023257dad37b9f8352e65e.1489060803.git.geliangtang@gmail.com>
        <03f9cf555a71fced65877c85e49fac7e880b338c.1489061285.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <03f9cf555a71fced65877c85e49fac7e880b338c.1489061285.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Sat, 11 Mar 2017 08:46:59 +0800

> Use setup_timer() instead of init_timer() to simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
