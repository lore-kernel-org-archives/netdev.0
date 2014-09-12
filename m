From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Resend] drivers: net: b44: Fix typo in returning
 multicast stats
Date: Fri, 12 Sep 2014 18:24:12 -0400 (EDT)
Message-ID: <20140912.182412.574409630539820830.davem@davemloft.net>
References: <1410473989-2049-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gary.zambrano@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mark.einon@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410473989-2049-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Einon <mark.einon@gmail.com>
Date: Thu, 11 Sep 2014 23:19:49 +0100

> nstat->multicast refers to received packets, not transmitted as
> is returned here. Change it so that received packet stats are
> given.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>

Applied, thank you.
