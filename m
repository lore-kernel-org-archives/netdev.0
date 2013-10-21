From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: moxa: remove duplicate includes
Date: Mon, 21 Oct 2013 18:47:19 -0400 (EDT)
Message-ID: <20131021.184719.447059170292983994.davem@davemloft.net>
References: <1382246036-19253-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382246036-19253-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Sun, 20 Oct 2013 07:13:56 +0200

> Reported by "make includecheck"
> 
> Tested that drivers/net/ethernet/moxa/moxart_ether.c still compiles
> well on ARM
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
