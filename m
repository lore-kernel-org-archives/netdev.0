From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc1: hangs when logging in to X session
Date: Mon, 5 Nov 2007 17:26:32 +0800
Message-ID: <20071105092632.GA10468@gondor.apana.org.au>
References: <fg4qau$9mg$1@ger.gmane.org> <fg4tbq$kum$1@ger.gmane.org> <20071101163138.382e249b.akpm@linux-foundation.org> <200711050955.32881.marcus@better.se> <20071105010308.6bd33fb1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcus Better <marcus@better.se>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2023 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753063AbXKEJ1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 04:27:35 -0500
Content-Disposition: inline
In-Reply-To: <20071105010308.6bd33fb1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2007 at 01:03:08AM -0800, Andrew Morton wrote:
> On Mon, 5 Nov 2007 09:55:32 +0100 Marcus Better <marcus@better.se> wrote:
> 
> > Andrew Morton wrote:
> > > > My laptop hangs when I try to log in to X with the current git kernel
> > > > (commit 2a397e82c7db18019e408f953dd58dc1963a328c). It runs fine with
> > > > 2.6.23. At boot time kdm starts normally, but hangs with the caps lock
> > > > LED blinking immediately after I press Enter after typing the password.

This was fixed after the changeset you quoted so if you update
to the latest it should work again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
