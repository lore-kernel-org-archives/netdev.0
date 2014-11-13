From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix sleeping function called from invalid context
Date: Thu, 13 Nov 2014 15:05:37 -0500 (EST)
Message-ID: <20141113.150537.1456498824246847470.davem@davemloft.net>
References: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, magnus.damm@gmail.com,
	linux-sh@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Thu, 13 Nov 2014 16:02:13 +0900

> This series is based on net tree.

A header posting is supposed to explain things, at a high level,
about the patch series.

For example, what is the patch series doing, and why.  What is the
context of the changes, is it meant to fix a specific bug report,
and if so which one?

Both of your sh_eth patch series have this problem.
