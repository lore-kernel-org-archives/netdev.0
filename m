From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: PATCH: kmalloc packet slab
Date: Tue, 28 Dec 2004 00:51:28 +0000
Message-ID: <1104195085.20898.62.camel@localhost.localdomain>
References: <1104156983.20944.25.camel@localhost.localdomain>
	 <41D043AC.2070203@trash.net>  <20041227142350.1cf444fe.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, torvalds@osdl.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262014AbUL1B4R@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041227142350.1cf444fe.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Llu, 2004-12-27 at 22:23, David S. Miller wrote:
> If we are really going to do something like this, it should
> be calculated properly and be determined per-interface
> type as netdevs are registered.

Fine by me, I'm just going through plausible looking changes in the Red
Hat tree. You might want to slightly injure someone internally until
they drop that too 8)

Alan
