From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 1/1] NET: ipv6, fix potential null dereference
Date: Sun, 10 Jan 2010 12:37:08 +0100
Message-ID: <4B49BBE4.2010502@gmail.com>
References: <20100110103528.GA4769@x200> <4B49AE41.5000206@gmail.com> <20100110104742.GC4769@x200> <4B49B463.3010502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:47492 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab0AJLhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 06:37:12 -0500
Received: by fg-out-1718.google.com with SMTP id 22so357902fge.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 03:37:10 -0800 (PST)
In-Reply-To: <4B49B463.3010502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2010 12:05 PM, Jiri Slaby wrote:
> And until people start to look at the reports for their stuff
> themselves, they will get bogus fixes from others. And they have to nack
> them, indeed.

Plus people sending such patches should plug in their brain. The tty
case is clearly bogus.
