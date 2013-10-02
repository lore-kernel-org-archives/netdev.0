From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net:drivers/net: Miscellaneous
 conversions to ETH_ALEN
Date: Wed, 02 Oct 2013 17:05:21 -0400 (EDT)
Message-ID: <20131002.170521.463969346066312216.davem@davemloft.net>
References: <1380679480.2081.24.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brcm80211-dev-list@broadcom.com, bridge@lists.linux-foundation.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ath10k@lists.infradead.org,
	wil6210@qca.qualcomm.com, netfilter-devel@vger.kernel.org,
	b43-dev@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
To: joe@perches.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1380679480.2081.24.camel@joe-AO722>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 01 Oct 2013 19:04:40 -0700

> Convert the memset/memcpy uses of 6 to ETH_ALEN
> where appropriate.
> 
> Also convert some struct definitions and u8 array
> declarations of [6] to ETH_ALEN.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Looks fine, applied, thanks Joe.
