From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net:set valid name before calling ndo_init()
Date: Fri, 13 May 2011 16:50:04 -0400 (EDT)
Message-ID: <20110513.165004.1636748018642899792.davem@davemloft.net>
References: <1305251217-4254-1-git-send-email-panweiping3@gmail.com>
	<20110513071508.GC2733@psychotron>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panweiping3@gmail.com, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jpirko@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110513071508.GC2733@psychotron>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 13 May 2011 09:15:09 +0200

> Fri, May 13, 2011 at 03:46:56AM CEST, panweiping3@gmail.com wrote:
>>In commit 1c5cae815d19 (net: call dev_alloc_name from register_netdevice),
>>a bug of bonding was invloved, see example 1 and 2.
 ...
> 
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks everyone.
