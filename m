From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [BRIDGE]
Date: Wed, 25 May 2005 09:14:27 -0700
Message-ID: <20050525091427.35621a21@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.62.0505241024580.19687@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505241024580.19687@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 May 2005 10:29:25 +0300 (EEST)
"Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro> wrote:

> Hello!
> 
> This patch set bridge device features using the common features of all 
> slaves. Also, it reacts to features change using ethtool on the slaves.
> 
> This patch depends on NETDEV_FEAT_CHANGE.patch.
> 

I will add it to the next set of patches for bridging. Hold off until
2.6.13
