From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] arping: Call usage() before limiting capabilities.
Date: Thu, 29 Nov 2012 03:18:18 +0900
Message-ID: <50B6556A.6040700@linux-ipv6.org>
References: <1354018775-4966-1-git-send-email-jsynacek@redhat.com> <1354018775-4966-2-git-send-email-jsynacek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jan Synacek <jsynacek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56322 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752392Ab2K1SSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 13:18:20 -0500
In-Reply-To: <1354018775-4966-2-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Synacek wrote:
> Otherwise, running arping binary without the capabilities set results in printing
> warnings with the usage.
> 
> Signed-off-by: Jan Synacek <jsynacek@redhat.com>

Fixed in different way.  ping/ping6 has also been fixed.
Thank you.

--yoshfuji
