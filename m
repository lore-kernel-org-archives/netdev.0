From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: Make selftest modular
Date: Fri, 30 Jan 2015 18:06:47 -0800 (PST)
Message-ID: <20150130.180647.696692403438716591.davem@davemloft.net>
References: <1422542425-20940-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422542425-20940-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 29 Jan 2015 15:40:25 +0100

> Allow the selftest on the resizable hash table to be built modular, just
> like all other tests that do not depend on DEBUG_KERNEL.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied to net-next, thanks.
