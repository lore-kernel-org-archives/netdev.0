From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [patch 2.6.12-rc5] tg3: add bcm5752 entry to pci.ids
Date: Fri, 27 May 2005 12:24:19 -0700
Message-ID: <1117221859.4310.6.camel@rh4>
References: <04132005193844.8474@laptop>
 <20050421165956.55bdcb14.davem@davemloft.net>
 <20050527184750.GB11592@tuxdriver.com>
 <20050527.123037.68041200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262574AbVE0UZY@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050527.123037.68041200.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2005-05-27 at 12:30 -0700, David S. Miller wrote:

> I'll apply this, thanks John.
> 
> pci.ids needs several updates for tg3 in fact, and it
> also now needs entries for bnx2 as well.
> 

The bnx2 IDs are already in, probably from sourceforge. And the tg3 IDs
look reasonably complete to me.

So in the future, do we need to patch this file or just let sourceforge
take care of it?
