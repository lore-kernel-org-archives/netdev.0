From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: next-20081209: build problem at arch/ia64/hp/sim/simeth.c
Date: Tue, 9 Dec 2008 17:11:17 +0300
Message-ID: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: linux-next@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	linux-ia64@vger.kernel.org
Return-path: <linux-ia64-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  CC      arch/ia64/hp/sim/simeth.o
arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no
member named 'open'
arch/ia64/hp/sim/simeth.c:213: error: 'struct net_device' has no
member named 'stop'
arch/ia64/hp/sim/simeth.c:214: error: 'struct net_device' has no
member named 'hard_start_xmit'
arch/ia64/hp/sim/simeth.c:215: error: 'struct net_device' has no
member named 'get_stats'
arch/ia64/hp/sim/simeth.c:216: error: 'struct net_device' has no
member named 'set_multicast_list'
