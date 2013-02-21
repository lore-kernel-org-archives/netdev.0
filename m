From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 20 Feb 2013 19:05:24 -0800
Message-ID: <CA+55aFz=tzf9a-SY1CqCAxsqRDz=ebE69YoZ30at6kHeKKhsaA@mail.gmail.com>
References: <20130220.170901.343210063003534302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f45.google.com ([209.85.212.45]:39900 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab3BUDFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 22:05:45 -0500
In-Reply-To: <20130220.170901.343210063003534302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2013 at 2:09 PM, David Miller <davem@davemloft.net> wrote:
>
> 15) Orphan and delete a bunch of pre-historic networking drivers from
>     Paul Gortmaker.

Nooo.... You killed the 3c501 and 3c503 drivers! Snif.

I wonder if they still worked..

             Linus
