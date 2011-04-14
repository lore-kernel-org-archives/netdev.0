From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/1] ipv6: RTA_PREFSRC support for ipv6 route source
 address selection
Date: Thu, 14 Apr 2011 23:24:00 +0900
Message-ID: <1302791040.9279.2.camel@takos>
References: <20110414071057.GB78446@0x90.at>  <4DA6FE25.70608@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: Daniel Walter <sahne@0x90.at>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
To: sclark46@earthlink.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DA6FE25.70608@earthlink.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Clark wrote:
> On 04/14/2011 03:10 AM, Daniel Walter wrote:
> > [ipv6] Add support for RTA_PREFSRC
> >
> > This patch allows a user to select the preferred source address
> > for a specific IPv6-Route. It can be set via a netlink message
> > setting RTA_PREFSRC to a valid IPv6 address which must be
> > up on the device the route will be bound to.

> What userspace application will be used to set this?

I do expect Daniel will submit appropriate patch for iproute2 package
shortly :-)

--yoshfuji
