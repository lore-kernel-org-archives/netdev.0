From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 01/15] bpf: BPF support for sock_ops
Date: Thu, 29 Jun 2017 11:47:18 +0200
Message-ID: <5954CCA6.5070500@iogearbox.net>
References: <20170620030048.3275347-1-brakmo@fb.com> <20170620030048.3275347-2-brakmo@fb.com> <594C47A1.1080102@iogearbox.net> <B03E3B5A-50E2-4291-B091-23927AF6846F@fb.com> <594C5065.2010900@iogearbox.net> <82AC8CB1-F770-4EFA-9223-E2C94626582F@fb.com> <594D84EA.5080203@iogearbox.net> <E7B3D347-2AFE-454F-9BDC-17CA7C18D291@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <Kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45290 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbdF2JrU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 05:47:20 -0400
In-Reply-To: <E7B3D347-2AFE-454F-9BDC-17CA7C18D291@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2017 07:45 PM, Lawrence Brakmo wrote:
[...]
> Daniel, thank you for the feedback. I just submitted a new patch set without
> the global program and using bpf cgroups framework.

Awesome, thanks for working on it!
