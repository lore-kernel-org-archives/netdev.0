From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/7] ebpf: constify various function pointer structs
Date: Tue, 10 Feb 2015 16:43:23 -0800
Message-ID: <CAMEtUuyR41Svwe-0Kk7jCHCxHwyBOyYdneAOmh9u6n36bwWovA@mail.gmail.com>
References: <cover.1423610452.git.daniel@iogearbox.net> <1be48c6154312f8c3fd239c26fae856fa3416bd8.1423610452.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:39120 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbbBKAno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:43:44 -0500
Received: by mail-qg0-f41.google.com with SMTP id i50so394320qgf.0
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:43:43 -0800 (PST)
In-Reply-To: <1be48c6154312f8c3fd239c26fae856fa3416bd8.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 4:15 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> We can move bpf_map_ops and bpf_verifier_ops and other structs
> into RO section, bpf_map_type_list and bpf_prog_type_list into
> read mostly.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

sure. makes sense.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
