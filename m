From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ks8851: Use dev_pm_ops
Date: Mon, 08 Apr 2013 16:56:34 -0400 (EDT)
Message-ID: <20130408.165634.559631606627992397.davem@davemloft.net>
References: <1365327184-22956-1-git-send-email-lars@metafoo.de>
	<1365327184-22956-2-git-send-email-lars@metafoo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben-linux@fluff.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lars@metafoo.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365327184-22956-2-git-send-email-lars@metafoo.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars-Peter Clausen <lars@metafoo.de>
Date: Sun,  7 Apr 2013 11:33:04 +0200

> Use dev_pm_ops instead of the deprecated legacy suspend/resume callbacks.
> 
> Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>

Applied.
