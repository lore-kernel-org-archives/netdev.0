From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sock: use hlist_entry_safe
Date: Fri, 20 Jan 2017 11:39:01 -0500 (EST)
Message-ID: <20170120.113901.936454754657068234.davem@davemloft.net>
References: <697f2692562e48afa03304a7e605e8adbee8437e.1484829069.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <697f2692562e48afa03304a7e605e8adbee8437e.1484829069.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Fri, 20 Jan 2017 22:27:04 +0800

> Use hlist_entry_safe() instead of open-coding it.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
