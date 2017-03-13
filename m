From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ambassador: use setup_timer
Date: Sun, 12 Mar 2017 23:47:54 -0700 (PDT)
Message-ID: <20170312.234754.1206357348898769963.davem@davemloft.net>
References: <3afa5498142ef68256023257dad37b9f8352e65e.1489060803.git.geliangtang@gmail.com>
        <964049df314453bb891ce71df7cd7a63540e6210.1489061130.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <964049df314453bb891ce71df7cd7a63540e6210.1489061130.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Sat, 11 Mar 2017 08:46:56 +0800

> Use setup_timer() instead of init_timer() to simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
