From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rhashtable: Make selftest modular
Date: Thu, 29 Jan 2015 22:14:39 +0000
Message-ID: <20150129221439.GA12928@casper.infradead.org>
References: <1422542425-20940-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422542425-20940-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/29/15 at 03:40pm, Geert Uytterhoeven wrote:
> Allow the selftest on the resizable hash table to be built modular, just
> like all other tests that do not depend on DEBUG_KERNEL.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

LGTM

Acked-by: Thomas Graf <tgraf@suug.ch>
