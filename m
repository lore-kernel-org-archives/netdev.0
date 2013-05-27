From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address workaround
 on DT ethernet
Date: Mon, 27 May 2013 19:39:25 +1000
Message-ID: <1369647565.3557.28.camel@pasglop>
References: <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <20130525.210441.818472895703230779.davem@davemloft.net>
 <51A26B62.4050009@gmail.com>
 <20130527.022339.791886107453761860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, jason@lakedaemon.net, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, buytenh@wantstofly.org, grant.likely@linaro.org,
 linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20130527.022339.791886107453761860.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-27 at 02:23 -0700, David Miller wrote:
> Sparc has an of_set_property(), it needs to become generic.

There is an of_update_property(), we could change the name though, yours
is nicer :-)

Cheers,
Ben.
