From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [stable] [PATCH 3/6] sky2: allow 88E8056
Date: Wed, 16 May 2007 18:23:54 -0700
Message-ID: <20070517012354.GB3429@sequoia.sous-sol.org>
References: <20070515220821.676720721@linux-foundation.org> <20070515220903.648019094@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:40959 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756382AbXEQB0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 21:26:01 -0400
Content-Disposition: inline
In-Reply-To: <20070515220903.648019094@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> It looks like the problems of Gigabyte 88E8056 are unique to that chip
> motherboard and maybe fixable by EEPROM update.

So, drop the Gigabyte hunks in the original patch...ok, thanks.
-chris
