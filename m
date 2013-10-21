From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cgxb4: remove duplicate include in cxgb4.h
Date: Mon, 21 Oct 2013 18:47:14 -0400 (EDT)
Message-ID: <20131021.184714.1113853778832206143.davem@davemloft.net>
References: <1382245801-19192-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382245801-19192-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Sun, 20 Oct 2013 07:10:01 +0200

> Reported by "make includecheck"
> 
> Tested that C sources including this file still compile well on x86
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
