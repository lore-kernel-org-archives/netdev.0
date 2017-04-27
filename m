From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: Re: [RFC net-next 2/2] bpf: Test for bpf_prog ID and
 BPF_PROG_GET_NEXT_ID
Date: Thu, 27 Apr 2017 09:23:18 +0200
Message-ID: <20170427072318.GA4734@gmail.com>
References: <20170427062449.80290-1-kafai@fb.com>
 <20170427062449.80290-3-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <ast@fb.com>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34140 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933802AbdD0HXX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 03:23:23 -0400
Received: by mail-wm0-f43.google.com with SMTP id r190so3447634wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 00:23:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170427062449.80290-3-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:24:49PM -0700, Martin KaFai Lau wrote:
> Add test to exercise the bpf_prog id generation
> and iteration.
> 
Could test_prog_id be a function in tools/testing/selftests/bpf/test_progs.c
instead? bpf_prog_load is already available there.

-- 
Mit freundlichen Grüßen

Alexander Alemayhu
