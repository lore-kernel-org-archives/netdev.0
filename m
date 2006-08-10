From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE 00/03]: Increase number of possible routing tables
Date: Fri, 11 Aug 2006 01:23:47 +0200
Message-ID: <44DBC003.50107@trash.net>
References: <20060810221447.9060.5563.sendpatchset@localhost.localdomain> <20060810161320.168674c8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:28904 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932286AbWHJXXu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 19:23:50 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060810161320.168674c8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Applied thanks. Let me know when your done, it has been too long
> since a real release of iproute2. I'll roll one as soon as the flow subsides.


I only have one more patchset I would like to submit soon, the time
cleanups. But they are only meant to make auditing for integer overflows
easier, so we can one day switch to a higher clock resolution. iproute
seems to be mostly fine, but the kernel will probably take a bit longer,
so I wouldn't mind missing this release. I'll submit them in the next
days anyway, but feel free to release without them.

