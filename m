From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] etherdevice: Rename
 random_ether_addr to eth_random_addr
Date: Mon, 16 Jul 2012 03:29:01 -0700 (PDT)
Message-ID: <20120716.032901.1657058688119342783.davem@davemloft.net>
References: <1341968967.13724.23.camel@joe2Laptop>
	<cover.1342157022.git.joe@perches.com>
	<20120716101437.GC22638@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org,
	wimax@linuxwimax.org, linux-mips@linux-mips.org,
	user-mode-linux-user@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	user-mode-linux-devel@lists.sourceforge.net, joe@perches.com,
	uclinux-dist-devel@blackfin.uclinux.org, johannes@sipsolutions.net
To: balbi@ti.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120716101437.GC22638@arwen.pp.htv.fi>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Felipe Balbi <balbi@ti.com>
Date: Mon, 16 Jul 2012 13:14:38 +0300

> if you're really renaming the function, then this patch alone will break
> all of the below users. That should all be a single patch, I'm afraid.

It would help if you actually read his patches before saying what they
might or might not do.

He provides a macro in the first patch that provides the old name,
and this will get removed at the end.

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
