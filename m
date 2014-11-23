From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: Hyper-V: Deletion of an unnecessary check before the
 function call "vfree"
Date: Sat, 22 Nov 2014 17:27:14 -0800
Message-ID: <1416706034.17888.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <546DF9D7.6080801@users.sourceforge.net>
 <20141121.151503.1986113223309494197.davem@davemloft.net>
 <546FB98E.5070703@users.sourceforge.net>
 <20141121.172705.540279259389643572.davem@davemloft.net>
 <54712F8C.10206@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
 kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
 Julia Lawall <julia.lawall@lip6.fr>, devel@linuxdriverproject.org,
 David Miller <davem@davemloft.net>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <54712F8C.10206@users.sourceforge.net>
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

On Sun, 2014-11-23 at 01:51 +0100, SF Markus Elfring wrote:
> > This has nothing to do with me asking you to frame your patches
> > against the correct tree.
> 
> I imagine than someone other can also pick up this update suggestion
> (a simple change of two lines) quicker before I might try another
> software build again from a different commit as a base.

I have no idea why someone would do that.

If you don't bother resubmit, nobody will.
