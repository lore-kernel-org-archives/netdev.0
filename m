From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [RFC PATCH v2 net-next 1/7] tcp: Carry txstamp_ack in tcp_fragment_tstamp
Date: Tue, 19 Apr 2016 13:44:01 -0400
Message-ID: <CACSApva6Xmd6eaoyLfg=TvBRVdZXE9mR3nj9bDd=PCr+n=m9pQ@mail.gmail.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
 <1461019569-3037369-2-git-send-email-kafai@fb.com> <CACSApvaRU64xz0N8CVdZrQ__i9MS2aAh5X1kKwhjdv3hz-OU9w@mail.gmail.com>
 <20160419173911.GB39131@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33309 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715AbcDSRom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 13:44:42 -0400
Received: by mail-ob0-f181.google.com with SMTP id tz8so18686021obc.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 10:44:41 -0700 (PDT)
In-Reply-To: <20160419173911.GB39131@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 1:39 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Tue, Apr 19, 2016 at 01:21:04AM -0400, Soheil Hassas Yeganeh wrote:
>> Could you please submit the timestamping patches separately as non RFCs? Thanks!
> Agree.  I will re-spin.

Great, thank you very much!
