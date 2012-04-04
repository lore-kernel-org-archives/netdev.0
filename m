From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] vxge: Convert macro to inline function
Date: Wed, 04 Apr 2012 15:37:55 -0700
Message-ID: <1333579075.23520.19.camel@joe2Laptop>
References: <1333489992.2695.17.camel@joe2Laptop>
	 <20120403.175837.1897033408784057713.davem@davemloft.net>
	 <1333491271.2695.20.camel@joe2Laptop>
	 <20120403.181830.799733266830291210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59171 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757050Ab2DDWh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 18:37:57 -0400
In-Reply-To: <20120403.181830.799733266830291210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 18:18 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 03 Apr 2012 15:14:31 -0700
> > Convert the macro to inline function to check the arguments.
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> >> Longer term I'd much rather see this turned into an inline
> >> function with proper type checking etc.
> > Something like this?
> Yep.

I did sign the patch.
I was intending that you could apply it.
Do you want a resend?
