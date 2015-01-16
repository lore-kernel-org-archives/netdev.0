From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] net: rps: fix cpu unplug
Date: Thu, 15 Jan 2015 17:21:21 -0800
Message-ID: <1421371281.11734.112.camel@edumazet-glaptop2.roam.corp.google.com>
References: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
	 <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4504851fe2f44615e67cde94286a2fdd.squirrel@www.codeaurora.org>
	 <1421350095.11734.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421358383.11734.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421370262.11734.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Prasad Sodagudi <psodagud@codeaurora.org>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:53126 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbbAPBVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 20:21:23 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so18333978iec.1
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 17:21:22 -0800 (PST)
In-Reply-To: <1421370262.11734.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 17:04 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 

Small note : this patch was based on net-next but applies correctly to
net tree

Hunk #1 succeeded at 7072 (offset -3 lines).
Hunk #2 succeeded at 7096 (offset -3 lines).
