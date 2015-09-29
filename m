From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: vlan: add per-vlan struct and
 move to rhashtables
Date: Tue, 29 Sep 2015 13:37:01 -0700 (PDT)
Message-ID: <20150929.133701.1255992517705127335.davem@davemloft.net>
References: <1443200411-7399-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com, vyasevich@gmail.com
To: razor@blackwall.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1443200411-7399-1-git-send-email-razor@blackwall.org>
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
Date: Fri, 25 Sep 2015 19:00:11 +0200

> This patch changes the bridge vlan implementation to use rhashtables
> instead of bitmaps.

This seems to be taking the code in a good direction, and I'm kinda
happy to see more rhashtable users in the tree as well.

So, applied to net-next, thanks.
