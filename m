From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] v2 GRE: Add segmentation offload for GRE
Date: Fri, 25 Jan 2013 11:52:18 -0800
Message-ID: <1359143538.12374.3379.camel@edumazet-glaptop>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
	 <1359070199.12374.2557.camel@edumazet-glaptop>
	 <CALnjE+rbqCgRwxr1TtFH92vKSJoTRhBP50f+jQmgWB9LanQhYw@mail.gmail.com>
	 <1359077664.12374.2887.camel@edumazet-glaptop>
	 <CALnjE+p0m7E7vH20M9mXuNiFG4iUpAsoyjW7ugez3ch=RdkVcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:43472 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab3AYTwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 14:52:21 -0500
Received: by mail-pb0-f42.google.com with SMTP id rp2so402028pbb.1
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 11:52:20 -0800 (PST)
In-Reply-To: <CALnjE+p0m7E7vH20M9mXuNiFG4iUpAsoyjW7ugez3ch=RdkVcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 19:38 -0800, Pravin Shelar wrote:

> I thought you were working on the fix. If not I will post patch.

I am working on a patch, will send it shortly.

As it is a stable candidate, I did a short one.
