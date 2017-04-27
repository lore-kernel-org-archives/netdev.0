From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC net-next 2/2] bpf: Test for bpf_prog ID and
 BPF_PROG_GET_NEXT_ID
Date: Thu, 27 Apr 2017 14:10:04 -0700
Message-ID: <20170427211004.xoldwffsrxuk3x77@kafai-mba.dhcp.thefacebook.com>
References: <20170427062449.80290-1-kafai@fb.com>
 <20170427062449.80290-3-kafai@fb.com>
 <20170427072318.GA4734@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
        "Hannes Frederic Sowa" <hannes@stressinduktion.org>,
        Alexei Starovoitov <ast@fb.com>, <kernel-team@fb.com>
To: Alexander Alemayhu <alexander@alemayhu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58247 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S968980AbdD0VKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 17:10:40 -0400
Content-Disposition: inline
In-Reply-To: <20170427072318.GA4734@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 09:23:18AM +0200, Alexander Alemayhu wrote:
> On Wed, Apr 26, 2017 at 11:24:49PM -0700, Martin KaFai Lau wrote:
> > Add test to exercise the bpf_prog id generation
> > and iteration.
> >
> Could test_prog_id be a function in tools/testing/selftests/bpf/test_progs.c
> instead? bpf_prog_load is already available there.
Will refactor to avoid duplication.

>
> --
> Mit freundlichen Grüßen
>
> Alexander Alemayhu
