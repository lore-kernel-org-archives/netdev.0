From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH v3 net-next] tcp: Remove use of daddr_cache in tracepoint
Date: Tue, 17 Oct 2017 17:25:10 -0700
Message-ID: <20171018002510.1641969-1-songliubraving@fb.com>
References: <1508276678.31614.118.camel.edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <xiyou.wangcong@gmail.com>,
        <dsahern@gmail.com>, Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45214 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753116AbdJRAZX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 20:25:23 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9I0M9w6019234
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 17:25:23 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2dns5brp64-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 17:25:23 -0700
In-Reply-To: <1508276678.31614.118.camel.edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Remove use of ipv6_pinfo in favor of data in sock_common.
> >
> > Fixes: e086101b150a ("tcp: add a tracepoint for tcp retransmission")
> > Signed-off-by: David Ahern <dsahern@gmail.com>
> > ---
>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

> Thanks David !

Tested-by: Song Liu <songliubraving@fb.com>
