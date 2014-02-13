From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] net: phy: use network device in phy_print_status
Date: Wed, 12 Feb 2014 19:22:19 -0500 (EST)
Message-ID: <20140212.192219.1616793147202715985.davem@davemloft.net>
References: <1392168462-18888-2-git-send-email-f.fainelli@gmail.com>
	<20140212.191313.1073971139703427607.davem@davemloft.net>
	<CAGVrzcZQA6g73PmRoN7BJ8qDpUi5avHGrQ03L8cT4_PGqh_ACg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbaBMAWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:22:20 -0500
In-Reply-To: <CAGVrzcZQA6g73PmRoN7BJ8qDpUi5avHGrQ03L8cT4_PGqh_ACg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 12 Feb 2014 16:20:19 -0800

> 2014-02-12 16:13 GMT-08:00 David Miller <davem@davemloft.net>:
>>
>> Series applied, but this patch series had several problems which I want you
>> absolutely to correct in future submissions.
>>
>> First of all, when you submit more than one patch at a time, you must
>> provide a leading "PATCH 00/NN" posting which gives a top-level,
>> detailed, description of the overall nature of the changes you are
>> submitting.
> 
> Weird, did not you receive this cover-letter:
> http://permalink.gmane.org/gmane.linux.network/303496
> if not, that probably explains why the threading was all messed up in
> your inbox.

Weird indeed, I'll watch out for this in the future.
