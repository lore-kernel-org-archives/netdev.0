From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Expose ip_vs_ftp module parameters via sysfs.
Date: Tue, 13 Sep 2011 11:22:45 +0900
Message-ID: <20110913022244.GJ30077@verge.net.au>
References: <1315818915-26288-1-git-send-email-krzysztof.wilczynski@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55474 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab1IMCWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 22:22:48 -0400
Content-Disposition: inline
In-Reply-To: <1315818915-26288-1-git-send-email-krzysztof.wilczynski@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2011 at 10:15:15AM +0100, Krzysztof Wilczynski wrote:
> This is to expose "ports" parameter via sysfs so it can be read
> at any time in order to determine what port or ports were passed
> to the module at the point when it was loaded.

Thanks Krzysztof,

I have queued this up locally and will forward it on for inclusion in 3.2
once the kernel.org hiatus is over.
