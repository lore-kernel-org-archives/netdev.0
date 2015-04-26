From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v4 RFC 00/15] introduce programable flow
 dissector and cls_flower
Date: Sun, 26 Apr 2015 22:57:47 +0300
Message-ID: <CAJ3xEMjgcS9q=shPLLBpxw0RqA+FFTD_SCkXeMODFmuJG8eQ9A@mail.gmail.com>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
	<CAJ3xEMj-BvNiQP_w_72K5MBC32hcybZ_KvEZvZLupGR6A8QQiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@nicira.com>,
	kaber@trash.net, Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	hannes@stressinduktion.org, Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	herbert@gondor.apana.org.au, Cong Wang <cwang@twopensource.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34090 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbbDZT5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 15:57:48 -0400
Received: by obfe9 with SMTP id e9so70014524obf.1
        for <netdev@vger.kernel.org>; Sun, 26 Apr 2015 12:57:48 -0700 (PDT)
In-Reply-To: <CAJ3xEMj-BvNiQP_w_72K5MBC32hcybZ_KvEZvZLupGR6A8QQiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 26, 2015 at 10:55 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Fri, Apr 24, 2015 at 6:51 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Per Davem's request, I prepared this patchset which introduces programmable
>> flow dissector. For current users of flow_keys, there is a wrapper
>> skb_flow_dissect_flow_keys which maintains the previous behaviour.
>> For purposes of cls_flower, couple of new dissection keys were introduced.

> From the subject line I conclude that this is the fifth version (V4),
> could you please point on  the previous four (V0-3) posts?

mmm, I see v3 now, it's just a single-patch sized series, which is
what confused me (and we start to count from zero... for next time)

Or.
