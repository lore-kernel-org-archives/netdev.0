From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 2.4/2.6 share in linux routers ?
Date: Sat, 28 Oct 2006 10:52:07 +0200
Message-ID: <20061028085207.GA28123@xi.wantstofly.org>
References: <f36b08ee0610271447s32f0c7bfk862d04e4bb826bbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:25510 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1752010AbWJ1IwK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Oct 2006 04:52:10 -0400
To: Yakov Lerner <iler.ml@gmail.com>
Content-Disposition: inline
In-Reply-To: <f36b08ee0610271447s32f0c7bfk862d04e4bb826bbd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 27, 2006 at 11:47:52PM +0200, Yakov Lerner wrote:

> I'd like to find/gather estimates about 2.4 vs 2.6 share in  [small]
> linux routers in 2006. Can anyone offer estimates and/or references ?

For ARM devices, 2.4 is still definitely in the majority.

The reason for that appears to be that embedded linux distro vendors
like locking their customers into their own patched-to-hell once-looked-
like-something-2.4-ish kernels, under the guise of a load of "2.6 is too
unstable" FUD.
