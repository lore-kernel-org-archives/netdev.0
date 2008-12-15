From: David Miller <davem@davemloft.net>
Subject: Re: kernel panics with net_rx_action on kernels >2.6.26
Date: Sun, 14 Dec 2008 22:48:00 -0800 (PST)
Message-ID: <20081214.224800.125614949.davem@davemloft.net>
References: <4945157C.9000305@sbg.ac.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: alexander.huemer@sbg.ac.at
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4945157C.9000305@sbg.ac.at>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Huemer <alexander.huemer@sbg.ac.at>
Date: Sun, 14 Dec 2008 15:17:32 +0100

Networking developers generally don't read the linux-net list, it is
for user configuration and basic questions only, not bug reports or
technical discussions.

netdev is the place to report such things, and I've added that to the
CC:

> one of my machines (x86) crashes under heavy network load with kernels
> >2.6.26, i tried quite everything possible between 2.6.27 and 2.6.28-rc8.
> 
> lspci -vv: http://xx.vu/~ahuemer/lspci_vv.txt <http://xx.vu/%7Eahuemer/lspci_vv.txt>
> of the quad nic 2 ports are used, the machine is acting as a iptables
> firewall/router.
> 
> kernel config (2.6.26) http://xx.vu/~ahuemer/config <http://xx.vu/%7Eahuemer/config>
> screenshot of the panic:
> http://xx.vu/~ahuemer/kernel_panic_net_rx_action.jpg <http://xx.vu/%7Eahuemer/kernel_panic_net_rx_action.jpg>
> 
> as i do not have any problems with kernels <=2.6.26, i doubt that this
> is a hardware problem.
> in case of the panic, nothing is written to the system log.
> 
> any hints welcome.
> please CC me on replies, i am not subscribed to the  mailing list.
