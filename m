From: David Miller <davem@davemloft.net>
Subject: Re: e1000e tx queue timeout in 3.3.0 (bisected to BQL
 support for e1000e)
Date: Tue, 01 May 2012 18:46:50 -0400 (EDT)
Message-ID: <20120501.184650.450772649940152534.davem@davemloft.net>
References: <20120501.174914.654247970871851432.davem@davemloft.net>
	<4FA05ED2.3030608@candelatech.com>
	<1335912148.2656.11.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, therbert@google.com,
	e1000-devel@lists.sourceforge.net
To: jeffrey.t.kirsher@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1335912148.2656.11.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 01 May 2012 15:42:28 -0700

> I will take care of the stable submission's Ben.

Actually, Jeff, hold off on that.

I misread Ben's email and didn't see that these were not
driver-specific changes.

Therefore, I'll take care of the -stable submissions and you don't
need to worry about it.

Thanks everyone.

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
