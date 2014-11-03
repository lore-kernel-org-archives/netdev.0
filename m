From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v3 1/3] syncookies: avoid magic values and
 document which-bit-is-what-option
Date: Mon, 03 Nov 2014 07:41:42 -0800
Message-ID: <1415029302.14083.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415019720-17106-1-git-send-email-fw@strlen.de>
	 <1415019720-17106-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:50879 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbaKCPlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 10:41:44 -0500
Received: by mail-ie0-f170.google.com with SMTP id tp5so5609696ieb.1
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 07:41:43 -0800 (PST)
In-Reply-To: <1415019720-17106-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 14:01 +0100, Florian Westphal wrote:
> Was a bit more difficult to read than needed due to magic shifts;
> add defines and document the used encoding scheme.
> 
> Joint work with Daniel Borkmann.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
