From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] qed*: Janitorial series [semantic &
 prints]
Date: Tue, 26 Jul 2016 11:07:29 -0700 (PDT)
Message-ID: <20160726.110729.1624227958625141431.davem@davemloft.net>
References: <1469541517-29934-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757852AbcGZSIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 14:08:07 -0400
In-Reply-To: <1469541517-29934-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 26 Jul 2016 16:58:34 +0300

> Some day 1 slips in coding style exist in the qed* code
> [incorrect alignments, conditions using (== 0), etc.].
> This series comes to address those, and do some additional
> cosmetic changes along the way [such as reducing the number of lines
> for function declerations].
> 
> The series is broken to 3 parts - purely semantic changes, cosmetic
> changes that required minor changes in the code, and print-related
> changes. All-in-all, no real change in driver behavior is expected.
> 
> Please consider applying this to `net-next'.

net-next is closed, please resubmit this after the merge window.

Thanks.
