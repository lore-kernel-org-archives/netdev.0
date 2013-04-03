From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH Resend] core: should call pskb_expand_head if skb header
 is cloned in skb_gso_segment in rx path
Date: Tue, 02 Apr 2013 18:19:50 -0700
Message-ID: <1364951990.5113.192.camel@edumazet-glaptop>
References: <1364783861-3363-1-git-send-email-roy.qing.li@gmail.com>
	 <1364905967.22165.4.camel@cr0>
	 <CAJFZqHxn77yUpGkOUzywVR7wg2_L8tFaLNrFyaauuLWPJsQUHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	jesse@nicira.com, pshelar@nicira.com, herbert@gondor.apana.org.au,
	edumazet@google.com
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:63185 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759067Ab3DCBTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 21:19:54 -0400
Received: by mail-da0-f46.google.com with SMTP id y19so425330dan.5
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 18:19:53 -0700 (PDT)
In-Reply-To: <CAJFZqHxn77yUpGkOUzywVR7wg2_L8tFaLNrFyaauuLWPJsQUHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-03 at 08:51 +0800, RongQing Li wrote:
> No, I just read and analyze it, and think it is bogus.

Please rewrite the changelog, because I read it several times and could
not understand it.
