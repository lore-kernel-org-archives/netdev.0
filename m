From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Removal of duplicated include
 net/wanrouter/wanmain.c
Date: Wed, 01 Aug 2007 21:50:58 -0700 (PDT)
Message-ID: <20070801.215058.105431907.davem@davemloft.net>
References: <46B0C9DD.8040701@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: michal.k.k.piotrowski@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754754AbXHBEvI@vger.kernel.org>
In-Reply-To: <46B0C9DD.8040701@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Date: Wed, 01 Aug 2007 19:58:53 +0200

> Hi,
> 
> There is no need to include linux/init.h twice
...
> Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

Patch applied, thanks.
