From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Wed, 25 Mar 2009 15:26:08 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0903251516460.31742@wrl-59.cs.helsinki.fi>
References: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com>
 <20090109031408.GB11336@gondor.apana.org.au> <20090109115515.GA12486@gondor.apana.org.au>
 <20090109120455.GB12486@gondor.apana.org.au> <49B0FD7D.5010004@haveacry.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	John Dykstra <john.dykstra1@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Dean Holland <speedster@haveacry.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37120 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761399AbZCYN0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 09:26:12 -0400
In-Reply-To: <49B0FD7D.5010004@haveacry.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Mar 2009, Dean Holland wrote:

> Have these commits made it into a kernel release yet? I haven't seen them in
> any of the Changelogs and am keen to get back to a packaged distribution
> kernel :)
> 
> Sorry if if I have missed it, but if not is there any indication of when it
> should make it in?

They are included in, commits:

a2bd40ad3151d4d346fd167e01fb84b06f7247fc
47e0e1ca13d64eeeb687995fbe4e239e743d7544

I think they are in 2.9.29-rc2 already and thus in 2.6.29 (if I read 
gitk's output correctly).

-- 
 i.
