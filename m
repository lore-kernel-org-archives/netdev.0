From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 16:49:29 -0700
Message-ID: <20070917164929.b53ac118.akpm@linux-foundation.org>
References: <20070916.202258.03371690.davem@davemloft.net>
	<20070917.141826.70218261.davem@davemloft.net>
	<20070917144037.100b3fc1.akpm@linux-foundation.org>
	<20070917231830.GG9282@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52654 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753424AbXIQXuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 19:50:11 -0400
In-Reply-To: <20070917231830.GG9282@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Sep 2007 19:18:30 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> P.S.  Andrew, I'll send you a link to a new git-wireless.patch --
> I'm sure you don't want a complicated git invocation...  Until then,
> I don't think you should try pulling wireless-dev...

OK, thanks.

The stuff I have now does actually compile, although the chances of it
actually working are epsilon.

So I'd rather not breathe on it today: I'l shove it out the door as-is
with a big "this is probably broken" label on it.   I'll at least test
ipw2200 before doing so.
