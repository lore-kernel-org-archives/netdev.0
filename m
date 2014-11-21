From: David Miller <davem@davemloft.net>
Subject: Re: net: Hyper-V: Deletion of an unnecessary check before the
 function call "vfree"
Date: Fri, 21 Nov 2014 17:27:05 -0500 (EST)
Message-ID: <20141121.172705.540279259389643572.davem@davemloft.net>
References: <546DF9D7.6080801@users.sourceforge.net>
 <20141121.151503.1986113223309494197.davem@davemloft.net>
 <546FB98E.5070703@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
 kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
 julia.lawall@lip6.fr, devel@linuxdriverproject.org
To: elfring@users.sourceforge.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <546FB98E.5070703@users.sourceforge.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 21 Nov 2014 23:15:42 +0100

>> This does not apply to the net-next tree, please respin.
> 
> Thanks for your reply.
> 
> How do you think about to try out the scripts which I published
> in March to get more constructive feedback?

This has nothing to do with me asking you to frame your patches
against the correct tree.

If I had time to investigate automation of changes using such
tools, I would participate in such discussions, but I don't.
