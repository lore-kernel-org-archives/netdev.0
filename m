From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute] ip: add support for multicast rules
Date: Wed, 19 May 2010 09:03:54 -0700
Message-ID: <20100519090354.6dc6d82b@nehalam>
References: <4BC48870.7070704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37450 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390Ab0ESQD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 12:03:57 -0400
In-Reply-To: <4BC48870.7070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Apr 2010 17:06:24 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch adds support for a "ip mrule" command, which is used
> to configure multicast routing rules.
> 
> The corresponding kernel patches have been sent to Dave and
> should (hopefully) appear in net-next soon.

The fib_rules.h file in iproute2 is kept in sync with the kernel
headers. But I do not see the definitions of FIB_RULES_IPV4 etc
in net-next kernel.  What happened to this?

