From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [openib-general] [PATCH 1/5] NetEffect 10Gb RNIC Userspace Library: userspace config generation
Date: Fri, 27 Oct 2006 10:56:45 -0700
Message-ID: <ada7iyl63s2.fsf@cisco.com>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9ECA@venom2>
	<1161959235.2748.1.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:30559 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1751313AbWJ0R4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 13:56:47 -0400
To: "Tom Tucker" <tom@opengridcomputing.com>
In-Reply-To: <1161959235.2748.1.camel@trinity.ogc.int> (Tom Tucker's message of "Fri, 27 Oct 2006 09:27:15 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I don't think the userspace stuff belongs on netdev. Someone please
 > correct me if I'm wrong.

Yeah, it's not a bad thing to get wider review, but your userspace
library is pretty much your business.  If you screw it up it doesn't
hurt anyone else, so I'm happy to let you write it however you want.

 - R.
