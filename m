From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: rtnl_bridge_getlink: Call
 nlmsg_find_attr() with ifinfomsg header
Date: Tue, 13 Aug 2013 16:31:27 -0700 (PDT)
Message-ID: <20130813.163127.1435008671852578392.davem@davemloft.net>
References: <52093E29.5010604@redhat.com>
	<20130813.155443.1789890841731289313.davem@davemloft.net>
	<520ABBFD.7080004@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, ast@fiberby.net,
	linux-kernel@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <520ABBFD.7080004@redhat.com>
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

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 13 Aug 2013 19:06:37 -0400

> ast explained it in his header message (Bridge VLAN kernel/iproute2
> incompatibility)

That's not a header message.

Header messages have a subject prefix of the form "[PATCH 0/N]".
If he had done this I wouldn't have had to ask such silly
questions.
