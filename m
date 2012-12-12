From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bridge: notify mdb changes via
	netlink
Date: Wed, 12 Dec 2012 13:03:21 -0500 (EST)
Message-ID: <20121212.130321.106719164539281219.davem@davemloft.net>
References: <1355300590-2390-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, herbert@gondor.hengli.com.au
To: amwang@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1355300590-2390-1-git-send-email-amwang@redhat.com>
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

From: Cong Wang <amwang@redhat.com>
Date: Wed, 12 Dec 2012 16:23:07 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> As Stephen mentioned, we need to monitor the mdb
> changes in user-space, so add notifications via netlink too.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
