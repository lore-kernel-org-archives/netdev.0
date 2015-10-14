From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 1/4] net_sched: introduce qdisc_replace() helper
Date: Wed, 14 Oct 2015 07:56:12 -0400
Message-ID: <561E42DC.2080502@mojatatu.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
 <1444675083-9825-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37813 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbbJNL4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 07:56:15 -0400
Received: by igbhv6 with SMTP id hv6so14864180igb.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 04:56:14 -0700 (PDT)
In-Reply-To: <1444675083-9825-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/15 14:38, Cong Wang wrote:
> Remove nearly duplicated code and prepare for the following patch.
>


Cong - like Dave, I dont see equivalence in some of these
changes.
Example not sure how the qfq grafting invocation of
qfq_purge_queue fits in. There are a few others.

cheers,
jamal
