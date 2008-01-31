From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] [IPV4]: Fix memory leak on error path during FIB
 initialization.
Date: Thu, 31 Jan 2008 05:14:44 -0800 (PST)
Message-ID: <20080131.051444.157479191.davem@davemloft.net>
References: <47A1B835.7050600@sw.ru>
	<1201780850-22216-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764437AbYAaNOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:14:23 -0500
In-Reply-To: <1201780850-22216-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 31 Jan 2008 15:00:45 +0300

> commit c8050bf6d84785a7edd2e81591e8f833231477e8
> Author: Denis V. Lunev <den@openvz.org>
> Date:   Thu Jan 10 03:28:24 2008 -0800

I am fixing it up for you this time, but please do not
reference the commit this way.

Say something like:

  blah blah blah in commit $(SHA1_HASH) ("commit head line").

The author and date give no real useful information in
this context, the important part is giving the reader
enough information to find the commit should they wish
to gain more information.

If they have the commit hash they can usually find the
commit, but if that fails they can search the commit
messages for the head line text string.

I feel like I've had to explain this 10 times in the past week...
:-/

