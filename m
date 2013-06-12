From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Wed, 12 Jun 2013 22:51:41 +0200
Message-ID: <1371070301.8601.37.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130612134812.2ff03429@samsung-9> (sfid-20130612_224826_767623_45A2542B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, romieu@fr.zoreil.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:43322 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab3FLUvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 16:51:49 -0400
In-Reply-To: <20130612134812.2ff03429@samsung-9> (sfid-20130612_224826_767623_45A2542B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-12 at 13:48 -0700, Stephen Hemminger wrote:
> pci_error_handlers should be const.

Indeed, thanks Stephen. I'll repost later (in the next couple of days.)

johannes
