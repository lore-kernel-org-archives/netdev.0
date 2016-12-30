From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] net: 3com: typhoon: typhoon_init_one: make
 return values more specific
Date: Fri, 30 Dec 2016 15:27:16 -0500 (EST)
Message-ID: <20161230.152716.1138757346265872327.davem@davemloft.net>
References: <1482873453.20986.4.camel@dillow-glaptop.roam.corp.google.com>
        <1483065474-11512-1-git-send-email-thomas.preisner+linux@fau.de>
        <1483065474-11512-3-git-send-email-thomas.preisner+linux@fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-kernel@i4.cs.fau.de,
        milan.stephan+linux@fau.de, sergei.shtylyov@cogentembedded.com
To: thomas.preisner+linux@fau.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483065474-11512-3-git-send-email-thomas.preisner+linux@fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Preisner <thomas.preisner+linux@fau.de>
Date: Fri, 30 Dec 2016 03:37:54 +0100

> In some cases the return value of a failing function is not being used
> and the function typhoon_init_one() returns another negative error code
> instead.
> 
> Signed-off-by: Thomas Preisner <thomas.preisner+linux@fau.de>
> Signed-off-by: Milan Stephan <milan.stephan+linux@fau.de>

Applied to net-next.
