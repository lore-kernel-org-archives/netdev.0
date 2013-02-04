From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] drivers/net: Remove unnecessary alloc/OOM messages
Date: Mon, 04 Feb 2013 13:23:35 -0500 (EST)
Message-ID: <20130204.132335.1757403310770538446.davem@davemloft.net>
References: <cover.1359939012.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, libertas-dev@lists.infradead.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-can@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, linux-hams@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: joe@perches.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1359939012.git.joe@perches.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun,  3 Feb 2013 19:28:07 -0800

> Remove all the OOM messages that follow kernel alloc
> failures as there is already a generic equivalent to
> these messages in the mm subsystem.
> 
> Joe Perches (8):
>   caif: Remove unnecessary alloc/OOM messages
>   can: Remove unnecessary alloc/OOM messages
>   ethernet: Remove unnecessary alloc/OOM messages, alloc cleanups
>   drivers: net: usb: Remove unnecessary alloc/OOM messages
>   wan: Remove unnecessary alloc/OOM messages
>   wimax: Remove unnecessary alloc/OOM messages, alloc cleanups
>   wireless: Remove unnecessary alloc/OOM messages, alloc cleanups
>   drivers:net:misc: Remove unnecessary alloc/OOM messages

Series applied, thanks Joe.
