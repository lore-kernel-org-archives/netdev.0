From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hippi/rrunner: use memdup_user
Date: Mon, 08 May 2017 15:02:21 -0400 (EDT)
Message-ID: <20170508.150221.31439690674980922.davem@davemloft.net>
References: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
        <58733b05cfe6248e30471a59ad1faee7f2f71280.1493780932.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jes@trained-monkey.org, linux-hippi@sunsite.dk,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58733b05cfe6248e30471a59ad1faee7f2f71280.1493780932.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Sat,  6 May 2017 23:42:16 +0800

> Use memdup_user() helper instead of open-coding to simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
