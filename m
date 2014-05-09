From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] TBF man page fix (tbf is not classless)
Date: Fri, 9 May 2014 13:36:21 -0700
Message-ID: <20140509133621.7c652874@nehalam.linuxnetplumber.net>
References: <1399659174-20841-1-git-send-email-sergey@lobanov.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Sergey V. Lobanov" <sergey@lobanov.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:42375 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756796AbaEIUgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:36:25 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so4860859pad.30
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 13:36:25 -0700 (PDT)
In-Reply-To: <1399659174-20841-1-git-send-email-sergey@lobanov.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  9 May 2014 22:12:54 +0400
"Sergey V. Lobanov" <sergey@lobanov.in> wrote:

> TBF is not classless qdisc. man page corrected, added example
> describing the use of inner qdisc
> 
> Signed-off-by: Sergey V. Lobanov <sergey@lobanov.in>

Looks good, applied
