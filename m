From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hamradio: baycom: remove deprecated IRQF_DISABLED
Date: Mon, 30 Sep 2013 15:09:12 -0400 (EDT)
Message-ID: <20130930.150912.46415312099350726.davem@davemloft.net>
References: <1380133065-13712-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: t.sailer@alumni.ethz.ch, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1380133065-13712-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Wed, 25 Sep 2013 20:17:45 +0200

> This patch proposes to remove the IRQF_DISABLED flag
> from drivers/net/hamradio/baycom_*
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied to net-next, thanks.
