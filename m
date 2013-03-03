From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif_dev: fix sparse warnings for caif_flow_cb
Date: Sun, 03 Mar 2013 01:44:21 -0500 (EST)
Message-ID: <20130303.014421.1879042322636699922.davem@davemloft.net>
References: <1362253519-13014-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjur.brandeland@stericsson.com,
	linux-kernel@vger.kernel.org
To: silviupopescu1990@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362253519-13014-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Date: Sat,  2 Mar 2013 21:45:19 +0200

> This fixed the following sparse warning:
> net/caif/caif_dev.c:121:6: warning: symbol 'caif_flow_cb' was not
> declared. Should it be static?
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>

Applied.
