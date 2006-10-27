From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [openib-general] [PATCH 1/5] NetEffect 10Gb RNIC Userspace
 Library: userspace config generation
Date: Fri, 27 Oct 2006 11:01:04 -0700
Message-ID: <20061027110104.116a53bc@freekitty>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9ECA@venom2>
	<1161959235.2748.1.camel@trinity.ogc.int>
	<ada7iyl63s2.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Tom Tucker" <tom@opengridcomputing.com>,
	"Glenn Grundstrom" <ggrundstrom@NetEffect.com>,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15494 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751394AbWJ0SE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 14:04:26 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <ada7iyl63s2.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Oct 2006 10:56:45 -0700
Roland Dreier <rdreier@cisco.com> wrote:

>  > I don't think the userspace stuff belongs on netdev. Someone please
>  > correct me if I'm wrong.
> 
> Yeah, it's not a bad thing to get wider review, but your userspace
> library is pretty much your business.  If you screw it up it doesn't
> hurt anyone else, so I'm happy to let you write it however you want.
> 
>  - R.
>

I prefer a pointer to the project download source.
Seeing the userspace stuff helps answer questions where the administration
process is confusing (or could/should be done differently).

-- 
Stephen Hemminger <shemminger@osdl.org>
