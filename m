From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] bridge: Set vlan_features to allow
 offloads on vlans.
Date: Thu, 23 May 2013 18:51:43 -0700 (PDT)
Message-ID: <20130523.185143.2153136693537557435.davem@davemloft.net>
References: <1369244974-10160-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1369244974-10160-1-git-send-email-vyasevic@redhat.com>
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
Date: Wed, 22 May 2013 13:49:34 -0400

> When vlan device is configured on top of the brige, it does
> not support any offload capabilities because the bridge
> device does not initiliaze vlan_fatures.  Set vlan_fatures to
> be equivalent to hw_fatures.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied to net-next, thanks Vlad.
