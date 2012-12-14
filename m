From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] sctp: Change defaults on cookie hmac selection
Date: Fri, 14 Dec 2012 13:56:15 -0800
Message-ID: <CA+55aFyT5b9GmGX0kzMPQG795uojiiWjWxUBBG_-m9bfrThU=Q@mail.gmail.com>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34748 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378Ab2LNV4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 16:56:36 -0500
In-Reply-To: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 10:51 AM, Neil Horman <nhorman@tuxdriver.com> wrote:
>
> Tested by myself (allbeit fairly quickly).  All configuration combinations seems
> to work soundly.

Ok, looks good, but I suspect we should also re-introduce the "none"
choice we used to have.

No?

          Linus
