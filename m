From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for July 2 (pktgen)
Date: Mon, 02 Jul 2012 09:19:12 -0700
Message-ID: <4FF1CA00.6090906@xenotime.net>
References: <20120702172334.2618cae84cc57b4ec5a63ed7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120702172334.2618cae84cc57b4ec5a63ed7@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02/2012 12:23 AM, Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20120629:



on i386:

net/built-in.o: In function `pktgen_if_write':
pktgen.c:(.text+0x1eaed): undefined reference to `__divdi3'


-- 

~Randy
