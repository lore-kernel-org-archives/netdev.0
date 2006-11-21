From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv6/sit.c: make 2 functions static
Date: Mon, 20 Nov 2006 19:56:58 -0500 (EST)
Message-ID: <20061120.195658.70202271.davem@davemloft.net>
References: <20061117170232.GH31879@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:50091 "EHLO localhost")
	by vger.kernel.org with ESMTP id S1030618AbWKUA46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 19:56:58 -0500
To: bunk@stusta.de
In-Reply-To: <20061117170232.GH31879@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 17 Nov 2006 18:02:32 +0100

> This patch makes two needlessly global functions static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied to net-2.6.20, thanks Adrian.
