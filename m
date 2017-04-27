From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC net-next 0/2] Introduce bpf_prog ID and iteration
Date: Thu, 27 Apr 2017 14:14:54 -0700
Message-ID: <20170427211454.n53646zeb5ujzxjl@kafai-mba.dhcp.thefacebook.com>
References: <20170427062449.80290-1-kafai@fb.com>
 <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
        "Alexei Starovoitov" <ast@fb.com>, <kernel-team@fb.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51274 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1423042AbdD0VPN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 17:15:13 -0400
Content-Disposition: inline
In-Reply-To: <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 03:36:59PM +0200, Hannes Frederic Sowa wrote:
> It would help a lot if you could pass the prog_id back during program
> creation, otherwise it will be kind of difficult to get a hold on which
> program is where. ;)
Thanks for your feedback :).  Make sense.  I will look into it.
