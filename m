From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] selftests: add a generic testsuite for ethernet device
Date: Mon, 3 Apr 2017 15:27:41 +0200
Message-ID: <20170403132741.GC17550@lunn.ch>
References: <20170331125752.20074-1-clabbe.montjoie@gmail.com>
 <20170331125752.20074-2-clabbe.montjoie@gmail.com>
 <20170331141241.GH22609@lunn.ch>
 <20170403131526.GC30824@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shuah@kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170403131526.GC30824@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> By ifnum, you mean by the order that "ip link" gives ?

I've not checked if it remains in order as interfaces are hot
plugged/unplugged. But i guess you are running tests direct after
boot, and unplugs/replugs are unlikely?

      Andrew
