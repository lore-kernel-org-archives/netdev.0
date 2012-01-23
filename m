From: David Miller <davem@davemloft.net>
Subject: Re: [patch v1, kernel version 3.2.1] Source mode for macvlan
 interaface
Date: Mon, 23 Jan 2012 13:44:54 -0500 (EST)
Message-ID: <20120123.134454.589237945281379533.davem@davemloft.net>
References: <22013455.801327321838477.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22013455.801327321838477.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Mon, 23 Jan 2012 13:30:38 +0100 (CET)

> New mode of macvlan interface called "source" allows one to specify, which  frames are allowed to be received by given macvlan interface. This logic is used only on received frames on underlaying interface. The ability to send frames from macvlan interface through underlaying interface is not modified. This feature allows one to simulate 802.1x mac based VLAN bahaviour by using proper netlink message to configure this behavior with utililty such as "ip link" from iproute2 suite.

Please properly format your commit messages, this is just one ugly 485
character long line.  Add newlines every 70 characters or so.
