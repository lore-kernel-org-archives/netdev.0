From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bridge: netlink: add support for
 vlan_filtering attribute
Date: Mon, 10 Aug 2015 13:36:53 -0700 (PDT)
Message-ID: <20150810.133653.2183665032933289268.davem@davemloft.net>
References: <1438964658-2904-1-git-send-email-razor@blackwall.org>
	<1438965645-7841-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1438965645-7841-1-git-send-email-razor@blackwall.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri,  7 Aug 2015 19:40:45 +0300

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch adds the ability to toggle the vlan filtering support via
> netlink. Since we're already running with rtnl in .changelink() we don't
> need to take any additional locks.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
