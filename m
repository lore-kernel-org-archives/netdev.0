From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl/qe: Do not prefix header guard with CONFIG_
Date: Wed, 08 Jun 2016 11:09:11 -0700 (PDT)
Message-ID: <20160608.110911.474062382079780765.davem@davemloft.net>
References: <1465378616-6764-1-git-send-email-andreas.ziegler@fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: qiang.zhao@nxp.com, valentinrothberg@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: andreas.ziegler@fau.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465378616-6764-1-git-send-email-andreas.ziegler@fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Ziegler <andreas.ziegler@fau.de>
Date: Wed,  8 Jun 2016 11:36:56 +0200

> The CONFIG_ prefix should only be used for options which
> can be configured through Kconfig and not for guarding headers.
> 
> Signed-off-by: Andreas Ziegler <andreas.ziegler@fau.de>

Since this is fixing a patch that went via the networking tree, you
should have CC:'d netdev@vger.kernel.org

Applied.
