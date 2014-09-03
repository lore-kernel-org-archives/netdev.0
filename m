From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] net: treewide: Fix typo found in DocBook/networking.xml
Date: Wed, 03 Sep 2014 09:53:21 -0700
Message-ID: <54074781.50909@infradead.org>
References: <1409716755-1994-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org
To: Masanari Iida <standby24x7@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409716755-1994-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/02/14 20:59, Masanari Iida wrote:
> This patch fix spelling typo found in DocBook/networking.xml.
> It is because the neworking.xml is generated from comments
> in the source, I have to fix typo in comments within the source.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
>  include/linux/netdevice.h  | 4 ++--
>  include/net/wimax.h        | 2 +-
>  include/trace/events/irq.h | 4 ++--
>  net/core/datagram.c        | 2 +-
>  net/core/gen_estimator.c   | 2 +-
>  net/core/gen_stats.c       | 2 +-
>  net/core/skbuff.c          | 4 ++--
>  net/core/sock.c            | 4 ++--
>  net/socket.c               | 2 +-
>  9 files changed, 13 insertions(+), 13 deletions(-)


-- 
~Randy
