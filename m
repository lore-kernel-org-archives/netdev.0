From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH v2 net-next 1/7] tcp: Carry txstamp_ack in
 tcp_fragment_tstamp
Date: Tue, 19 Apr 2016 10:39:11 -0700
Message-ID: <20160419173911.GB39131@kafai-mba.local>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
 <1461019569-3037369-2-git-send-email-kafai@fb.com>
 <CACSApvaRU64xz0N8CVdZrQ__i9MS2aAh5X1kKwhjdv3hz-OU9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:5330 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915AbcDSRn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 13:43:26 -0400
Content-Disposition: inline
In-Reply-To: <CACSApvaRU64xz0N8CVdZrQ__i9MS2aAh5X1kKwhjdv3hz-OU9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 01:21:04AM -0400, Soheil Hassas Yeganeh wrote:
> Could you please submit the timestamping patches separately as non RFCs? Thanks!
Agree.  I will re-spin.
