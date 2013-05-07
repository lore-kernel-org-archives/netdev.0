From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 15/15] ptp: PTP_1588_CLOCK_PCH depends on x86
Date: Tue, 7 May 2013 21:29:38 +0200
Message-ID: <20130507192938.GA3599@netboy>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
 <1367936303-13386-15-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	Jeff Mahoney <jeffm@suse.com>, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:34030 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab3EGT3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 15:29:49 -0400
Content-Disposition: inline
In-Reply-To: <1367936303-13386-15-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 07, 2013 at 04:18:23PM +0200, Jiri Slaby wrote:
> From: Jeff Mahoney <jeffm@suse.com>
> 
> The PCH EG20T is only compatible with Intel Atom processors so it
> should depend on x86.

This patch has been submitted before,

   https://patchwork.kernel.org/patch/2069071/

and at that time the reaction was that it is good to have drivers
cross-compiled, if only for code quality reasons.

Thanks,
Richard
