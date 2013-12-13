From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 16:27:34 -0500
Message-ID: <52AB7BC6.9050503@mojatatu.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>	<1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>	<AE90C24D6B3A694183C094C60CF0A2F6026B7489@saturn3.aculab.com> <CAM_iQpVgo+nxN3eTRg_F9u+-k4ML+D3ZqsrAEOeLZwtU6dOk3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:60651 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696Ab3LMV1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:27:44 -0500
Received: by mail-ie0-f176.google.com with SMTP id at1so3550871iec.7
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:27:44 -0800 (PST)
In-Reply-To: <CAM_iQpVgo+nxN3eTRg_F9u+-k4ML+D3ZqsrAEOeLZwtU6dOk3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/13 13:33, Cong Wang wrote:

> Why? Keep in mind that we don't need to worry about any
> out-of-tree modules. :)

This is an API that is used to export additional stats that
are not generic.

cheers,
jamal
