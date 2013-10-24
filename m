From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] net:sched  fix a bug about memery leak
Date: Thu, 24 Oct 2013 18:10:00 +0400
Message-ID: <52692A38.8040705@cogentembedded.com>
References: <1382605964-2693-1-git-send-email-windsdaemon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jing Wang <windsdaemon@gmail.com>, davem@davemloft.net,
	jhs@mojatatu.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:43391 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890Ab3JXOKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 10:10:02 -0400
Received: by mail-lb0-f179.google.com with SMTP id w6so325279lbh.38
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 07:10:00 -0700 (PDT)
In-Reply-To: <1382605964-2693-1-git-send-email-windsdaemon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/24/2013 01:12 PM, Jing Wang wrote:

    s/mememry/memory/ in the subject.

> From: Jing Wang <windsdaemon@gmail.com>

> the code isn't properly release memory

    s/release/releasing/.

> Signed-off-by: Jing Wang <windsdaemon@gmail.com>

WBR, Sergei
