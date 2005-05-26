From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] [BRIDGE]
Date: Thu, 26 May 2005 08:49:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505260848300.7768@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505241024580.19687@webhosting.rdsbv.ro>
 <20050525091427.35621a21@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050525091427.35621a21@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 May 2005, Stephen Hemminger wrote:

> On Tue, 24 May 2005 10:29:25 +0300 (EEST)
> "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro> wrote:
>
>> Hello!
>>
>> This patch set bridge device features using the common features of all
>> slaves. Also, it reacts to features change using ethtool on the slaves.
>>
>> This patch depends on NETDEV_FEAT_CHANGE.patch.
>>
>
> I will add it to the next set of patches for bridging. Hold off until
> 2.6.13

Thanks, Stephen!

P.S. This patch needs NETDEV_FEAT_CHANGE.patch. Do you include both?

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
