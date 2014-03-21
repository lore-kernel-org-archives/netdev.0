From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v4] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Fri, 21 Mar 2014 15:32:37 -0400 (EDT)
Message-ID: <20140321.153237.2236797908349183626.davem@davemloft.net>
References: <20140321.144957.550032279989990583.davem@davemloft.net>
 <20140321.145501.2003616654661701935.davem@davemloft.net>
 <84837c9e73f24bcd8f652a24f616ff1e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <84837c9e73f24bcd8f652a24f616ff1e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri, 21 Mar 2014 19:12:43 +0000

> Could it be merged into net-next tree?

You submitted a patch against net-next, that means you are implicitly
stating that all dependencies are in place in _that_ tree and that
you tested it in _that_ tree.

If the situation is otherwise you must explicitly state this in your
patch submission.
