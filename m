From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Protect if_phonet.h against multiple inclusions.
Date: Wed, 01 Oct 2008 01:32:45 -0700 (PDT)
Message-ID: <20081001.013245.28898155.davem@davemloft.net>
References: <200810011054.52951.remi.denis-courmont@nokia.com>
	<1222847858-16706-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752588AbYJAIc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 04:32:57 -0400
In-Reply-To: <1222847858-16706-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed,  1 Oct 2008 10:57:38 +0300

> ---
>  include/linux/if_phonet.h |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)

Applied thanks.

Please provide a proper Signed-off-by line in the future,
even for trivial patches such as this one.
