From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] hsr: fix coding style issues
Date: Wed, 21 Jun 2017 14:58:03 -0400 (EDT)
Message-ID: <20170621.145803.1983601268766341859.davem@davemloft.net>
References: <1498060142-8925-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498060142-8925-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is way too much churn.

Especially renaming the structure members.

Just a blanket "I fixed a dozen of so checkpatch warnings" bundled
into a single huge patch like this will not be applied, sorry.
