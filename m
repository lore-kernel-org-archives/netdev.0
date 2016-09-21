From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 08:44:06 -0700
Message-ID: <57E2AAC6.8080000@fb.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <57E1CDE3.5030404@fb.com> <20160921083955.7cdba944@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>,
        <tariqt@mellanox.com>, <bblanco@plumgrid.com>,
        <alexei.starovoitov@gmail.com>, <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:32831 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754065AbcIUPp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:45:57 -0400
In-Reply-To: <20160921083955.7cdba944@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/16 11:39 PM, Jesper Dangaard Brouer wrote:
> We are the early stages of XDP development. Users cannot consider XDP a
> stable UAPI yet.  I added a big fat warning to the docs here[1].
>
> If you already consider this a stable API, then I will suggest that we
> disable XDP or rip the hole thing out again!!!

the doc that you wrote is a great description of your understanding
of what XDP is about. It's not an official spec or design document.
Until it is reviewed and lands in kernel.org, please do not
make any assumption about present or future XDP API based on it.
