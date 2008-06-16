From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: DM9000: Remove blackfin as special case.
Date: Mon, 16 Jun 2008 11:28:54 +0800
Message-ID: <386072610806152028j12f72dcbq30917415b7fca0a0@mail.gmail.com>
References: <20080615233648.597885961@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Ben Dooks" <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:8769 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbYFPD24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 23:28:56 -0400
Received: by yw-out-2324.google.com with SMTP id 9so3007520ywe.1
        for <netdev@vger.kernel.org>; Sun, 15 Jun 2008 20:28:55 -0700 (PDT)
In-Reply-To: <20080615233648.597885961@fluff.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 7:36 AM, Ben Dooks <ben-linux@fluff.org> wrote:
>

> The first part of remove the DEFAULT_TRIGGER should
> be relatively easy to fixup in whatever blackfin archs
> still use this.

I think, we can pass this irqflag from the platform resource.

> The otherbits, I would recommend the relevant blackfin
> IO headers should deal with defining the six functions to
> the relevant blackfin implementation.
>
> I would have sent this directly to the blackfin list, but
> it is marked as subscribers only.

Would you please send me your patch directly?

Thanks a lot
-Bryan
