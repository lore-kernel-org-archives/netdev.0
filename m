From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute] ipila: Fixed unitialized variables
Date: Wed, 17 Aug 2016 13:53:54 -0700
Message-ID: <20160817135354.23b081d5@xeon-e3>
References: <1471303822-1486672-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35460 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210AbcHQUxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 16:53:43 -0400
Received: by mail-pa0-f49.google.com with SMTP id i5so39376223pat.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 13:53:43 -0700 (PDT)
In-Reply-To: <1471303822-1486672-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Aug 2016 16:30:22 -0700
Tom Herbert <tom@herbertland.com> wrote:

> Initialize locator and locator_match to zero and only do
> addattr if they have been set.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied thanks
