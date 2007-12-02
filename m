From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [LIKELY_SPAM][git patches] net driver fixes
Date: Sat, 01 Dec 2007 16:01:16 -0800
Message-ID: <4751F5CC.8020904@chelsio.com>
References: <20071201233711.GA9698@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:15530 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047AbXLBAB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 19:01:29 -0500
In-Reply-To: <20071201233711.GA9698@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
>
> Notes:
>
> 1) Several of these are resends from the last submission.
>
> 2) That chelsio file mode change (644->755) is a bit annoying.  Can git
> do chmod as a changeset by itself?
>

Sorry for this. I had not noticed it.
If any help, I just submitted a patch reverting the file mode changes.

Cheers,
Divy
