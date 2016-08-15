From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH repost net-next 0/3] qed*: Janitorial series [semantic
 & prints]
Date: Mon, 15 Aug 2016 13:35:07 -0700 (PDT)
Message-ID: <20160815.133507.93499827123938857.davem@davemloft.net>
References: <1471246965-26031-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932115AbcHOUfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 16:35:13 -0400
In-Reply-To: <1471246965-26031-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 15 Aug 2016 10:42:42 +0300

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
> [This is a repost; Original was sent when net-next closed].
> 
> Please consider applying this to `net-next'.

Series applied, thanks.
