From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: remove deprecated IRQF_DISABLED
Date: Thu, 17 Oct 2013 15:14:54 -0400 (EDT)
Message-ID: <20131017.151454.701894564686762206.davem@davemloft.net>
References: <1381641869-7709-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381641869-7709-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Sun, 13 Oct 2013 07:24:29 +0200

> This patch proposes to remove the use of the IRQF_DISABLED flag
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied to net-next.
