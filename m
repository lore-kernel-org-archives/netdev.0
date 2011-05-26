From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for May 26 (drivers/net/caif)
Date: Thu, 26 May 2011 12:07:02 -0700
Message-ID: <20110526120702.fac24de0.randy.dunlap@oracle.com>
References: <20110526163941.7dfcad1a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110526163941.7dfcad1a.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 May 2011 16:39:41 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> [The kernel.org mirroring is being slow today]


(not new)

drivers/net/caif/caif_serial.c:194: warning: 'return' with no value, in function returning non-void
drivers/net/caif/caif_serial.c:202: warning: 'return' with no value, in function returning non-void


I'm curious:  how do warnings like this get overlooked?
too much noise in the build messages?  or it wasn't overlooked, just ignored?


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
