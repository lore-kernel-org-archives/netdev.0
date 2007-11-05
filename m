From: Marcus Better <marcus@better.se>
Subject: Re: 2.6.24-rc1: hangs when logging in to X session
Date: Mon, 5 Nov 2007 17:44:17 +0100
Message-ID: <200711051744.17607.marcus@better.se>
References: <fg4qau$9mg$1@ger.gmane.org> <20071105010308.6bd33fb1.akpm@linux-foundation.org> <20071105092632.GA10468@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iggypop2.siwnet.net ([81.216.65.12]:51278 "EHLO
	iggypop2.siwnet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753771AbXKEQyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 11:54:05 -0500
In-Reply-To: <20071105092632.GA10468@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> > > > > My laptop hangs when I try to log in to X with the current git
> > > > > kernel (commit 2a397e82c7db18019e408f953dd58dc1963a328c). It runs
> > > > > fine with 2.6.23. At boot time kdm starts normally, but hangs with
> > > > > the caps lock LED blinking immediately after I press Enter after
> > > > > typing the password.
>
> This was fixed after the changeset you quoted so if you update
> to the latest it should work again.

Yes, it works now. Thanks,

Marcus
