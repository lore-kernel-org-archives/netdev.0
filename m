From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Mon, 28 Aug 2017 16:42:08 -0700 (PDT)
Message-ID: <20170828.164208.1908438929113102094.davem@davemloft.net>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, samuel@sortiz.org,
 linux-kernel@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170827150334.32495-1-gregkh@linuxfoundation.org>
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

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 27 Aug 2017 17:03:30 +0200

> The IRDA code has long been obsolete and broken.  So, to keep people
> from trying to use it, and to prevent people from having to maintain it,
> let's move it to drivers/staging/ so that we can delete it entirely from
> the kernel in a few releases.

No objection, I'll apply this to net-next, thanks Greg.
