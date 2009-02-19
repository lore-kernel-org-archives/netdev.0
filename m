From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] netfilter code cleanup
Date: Fri, 20 Feb 2009 00:43:40 +0100
Message-ID: <1235087023-30451-1-git-send-email-hagen@jauu.net>
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42102 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754192AbZBTASE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 19:18:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I stumbled accross some unattractive code in the netfilter core.
These two patches try address them.

Best regards, Hagen Paul Pfeifer


