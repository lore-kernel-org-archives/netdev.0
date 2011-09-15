From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/8] tg3: Odds and ends
Date: Thu, 15 Sep 2011 15:57:24 -0400 (EDT)
Message-ID: <20110915.155724.790964459478256654.davem@redhat.com>
References: <1314827094-29714-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10311 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934532Ab1IOT50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 15:57:26 -0400
In-Reply-To: <1314827094-29714-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 31 Aug 2011 14:44:46 -0700

> This patchset applies a few minor changes and cleans up some
> unnecessary function prototypes.

Applied, but as Joe Perches stated patch #8 claimed it just was
"code movement" but a test in the code was changed.  Please don't
do that again.
