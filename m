From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [2.6 patch] hostap_{pci,plx}.c: fix memory leaks
Date: Tue, 14 Mar 2006 19:16:25 -0800
Message-ID: <20060315031625.GE9384@jm.kir.nu>
References: <20060313222841.GQ13973@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com, linux-kernel@vger.kernel.org
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060313222841.GQ13973@stusta.de>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2006 at 11:28:41PM +0100, Adrian Bunk wrote:
> This patch fixes two memotry leaks spotted by the Coverity checker.

Thanks. I'll make a bit different patch to resolve this and related PCI
"leaks" in one change. I'm going through the Coverity reports for Host
AP driver, so I'll include other fixes in a patch set, too.

-- 
Jouni Malinen                                            PGP id EFC895FA
