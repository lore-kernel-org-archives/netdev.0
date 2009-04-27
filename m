From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth: add clock gating feature
Date: Mon, 27 Apr 2009 12:24:47 -0700
Message-ID: <20090427122447.a006a21e.akpm@linux-foundation.org>
References: <49F5A5A7.4050609@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49691 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752673AbZD0T1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 15:27:36 -0400
In-Reply-To: <49F5A5A7.4050609@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Apr 2009 08:31:35 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> This patch adds support for clock gating the tx/rx engines which is 
> available on certain chipsets.

What are the effects of this patch?  Improved power management?  Fixes
a user-visible bug?  Something else?
