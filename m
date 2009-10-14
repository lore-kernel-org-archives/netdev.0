From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix OF platform drivers coldplug/hotplug when
	compiled as modules
Date: Wed, 14 Oct 2009 14:54:59 -0700 (PDT)
Message-ID: <20091014.145459.118730396.davem@davemloft.net>
References: <20091008121512.GA2390@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20091008121512.GA2390@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Thu, 8 Oct 2009 16:15:12 +0400

> Some OF platform drivers are missing module device tables, so they won't
> load automatically on boot. This patch fixes the issue by adding proper
> MODULE_DEVICE_TABLE() macros to the drivers.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks!
