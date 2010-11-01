From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Routing over multiple interfaces
Date: Mon, 1 Nov 2010 17:21:39 -0400
Message-ID: <20101101212139.GV23388@kvack.org>
References: <1288645922.5977.41.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:33421 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125Ab0KAVwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 17:52:25 -0400
Content-Disposition: inline
In-Reply-To: <1288645922.5977.41.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 01, 2010 at 05:12:02PM -0400, David Woodhouse wrote:
> I worked around this earlier today by splitting the large file I needed
> to upload into two parts, shifting one of them to a *different* machine,
> connecting that to the VPN too and then uploading the two parts
> separately. But that isn't really a viable option in the general case.

Have a look at eql.

		-ben
