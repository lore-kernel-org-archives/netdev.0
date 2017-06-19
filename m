From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pptp: Remove unused variable in pptp_release()
Date: Sun, 18 Jun 2017 23:54:13 -0400 (EDT)
Message-ID: <20170618.235413.1021692693636326315.davem@davemloft.net>
References: <1497800500-17897-1-git-send-email-chris.gekas@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chris.gekas@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497800500-17897-1-git-send-email-chris.gekas@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christos Gkekas <chris.gekas@gmail.com>
Date: Sun, 18 Jun 2017 16:41:40 +0100

> Variable opt in pptp_release() is set but never used, thus needs to be
> removed.
> 
> Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>

Applied to net-next.
