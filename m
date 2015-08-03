From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Stacked vlan TSO for virtual
	devices
Date: Mon, 03 Aug 2015 14:25:25 -0700 (PDT)
Message-ID: <20150803.142525.39592104527259955.davem@davemloft.net>
References: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, kaber@trash.net
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Fri, 31 Jul 2015 15:03:23 +0900

> Basically virtual devices do not need to segment double tagged packets.
> This patch set adds TSO feature for double tagged packets to several
> virtual devices, which can be realized by simply setting
> .ndo_features_check to passthru_features_check.

Series applied, thank you.
