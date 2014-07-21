From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/30] drivers/net: remove unnecessary
 break after return
Date: Sun, 20 Jul 2014 21:31:02 -0700 (PDT)
Message-ID: <20140720.213102.1007291311502673484.davem@davemloft.net>
References: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: brcm80211-dev-list@broadcom.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com,
	linuxppc-dev@lists.ozlabs.org
To: fabf@skynet.be
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1405865801-18806-1-git-send-email-fabf@skynet.be>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Sun, 20 Jul 2014 16:16:08 +0200

> Second patchset after "remove unnecessary break after goto" addressing break redundancy on drivers/net branch
> (suggested by Joe Perches)

All applied except the i40e patch, which did not apply to net-next at all.

------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
