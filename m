From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: ata and netdev (was Re: -mm merge plans for 2.6.23)
Date: Wed, 11 Jul 2007 00:31:23 +0400
Message-ID: <4693EC9B.6020305@ru.mvista.com>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	<4693C4F8.40903@garzik.org> <20070710112458.e9dbb55e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:16512 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760425AbXGJU3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 16:29:22 -0400
In-Reply-To: <20070710112458.e9dbb55e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Andrew Morton wrote:

> 3x59x-fix-pci-resource-management.patch: you wrote it ;) I have a comment

    No, I did, almost a year ago already. :-)

> here:

> - I don't remember the story with cardbus either.  Presumably once upon a
>   time the cardbus layer was claiming IO regions on behalf of cardbus
>   devices (?)

    IIRC, that's your own comment.

> Need to think about that.

WBR, Sergei
