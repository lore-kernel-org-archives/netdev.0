From: Patrick McHardy <kaber@trash.net>
Subject: Re: iptables bug
Date: Tue, 21 Jun 2005 01:39:20 +0200
Message-ID: <42B753A8.5050808@trash.net>
References: <20050619233029.45dd66b8.akpm@osdl.org>	<1119305756l.1344l.0l@werewolf.able.es>
	<20050620153445.5daaed4e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <20050620153445.5daaed4e.akpm@osdl.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> "J.A. Magallon" <jamagallon@able.es> wrote:
> 
>>Are there any known problems with iptables ?

No known problems.

>>I see strange things.
>>When I use bittorrent (azureus or bittorrent-gui), at the same time as
>>iptables (for nat and internet access for my ibook), when I stop a download
>>or exit from one of this apps my external network goes down. 
>>I have tried the same without iptables loaded and it works fine.

What exactly do you mean with "network goes down"? Can you find out
where the packets disappear? Do they silently disappear, or do you get
an error code from sendmsg? What about received packets?

Regards
Patrick
