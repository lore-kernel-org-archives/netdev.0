From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v11 net-next 00/12] VLAN filtering/VLAN aware
	bridge
Date: Wed, 13 Feb 2013 20:10:57 -0500 (EST)
Message-ID: <20130213.201057.1655520092052468880.davem@davemloft.net>
References: <1360792820-14116-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1360792820-14116-1-git-send-email-vyasevic@redhat.com>
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
Date: Wed, 13 Feb 2013 17:00:08 -0500

> Vlad Yasevich (12):
>   bridge: Add vlan filtering infrastructure
>   bridge: Validate that vlan is permitted on ingress
>   bridge: Verify that a vlan is allowed to egress on given port
>   bridge: Add netlink interface to configure vlans on bridge ports
>   bridge: Dump vlan information from a bridge port
>   bridge: Implement vlan ingress/egress policy with PVID.
>   bridge: Add the ability to configure pvid
>   bridge: Add vlan to unicast fdb entries
>   bridge: Add vlan id to multicast groups
>   bridge: Add vlan support to static neighbors
>   bridge: Add vlan support for local fdb entries
>   bridge: Separate egress policy bitmap

Series applied, thanks Vlad.
