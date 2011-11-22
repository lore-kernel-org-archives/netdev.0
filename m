From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/4] e1000e: ethtool
 setfeatures fixes + loopback
Date: Tue, 22 Nov 2011 15:49:27 -0500 (EST)
Message-ID: <20111122.154927.1808817488257424268.davem@davemloft.net>
References: <cover.1321917278.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, paul.gortmaker@windriver.com,
	e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, netdev@vger.kernel.org
To: david.decotigny@google.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1321917278.git.david.decotigny@google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


I would like to see some discussion wrt. Jamal's feedback, which is that
a lot of the side-band functionality added by this code is either 1) already
doable with packet scheduler actions or 2) should be implemented there.

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
