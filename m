From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Wed, 12 Jun 2013 13:48:12 -0700
Message-ID: <20130612134812.2ff03429@samsung-9>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	<1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, romieu@fr.zoreil.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:58920 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab3FLUsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 16:48:25 -0400
Received: by mail-ob0-f176.google.com with SMTP id v19so13854170obq.21
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 13:48:24 -0700 (PDT)
In-Reply-To: <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pci_error_handlers should be const.
