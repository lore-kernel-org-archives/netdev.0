From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: codel: split into multiple files
Date: Tue, 26 Apr 2016 08:09:06 +0200
Message-ID: <CA+icZUWrRbBJM3q7SzRSc2znAXZHr1JdXHD2j2POKvDin4=CZg@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34845 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbcDZGJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 02:09:07 -0400
Received: by mail-vk0-f47.google.com with SMTP id u23so5359639vkb.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 23:09:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I had a very quick view on net-next.git#master (up to commit
fab7b629a82da1b59620470d13152aff975239f6).

Commit in [1] aka "codel: split into multiple files" removed codel.h
but [2] and [3] have relicts to it.
Forgot to remove?
(Not sure if there exist more relicts.)

Regards,
- Sedat -


[1] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=d068ca2ae2e614b9a418fb3b5f1fd4cf996ff032
[2] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/net/sched/sch_codel.c#n51
[3] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/net/sched/sch_fq_codel.c#n26
