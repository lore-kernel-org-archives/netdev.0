From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Fri, 2 Jun 2017 05:39:50 -0600
Message-ID: <270a4662-fdee-0a4e-4835-1f671f409b17@gmail.com>
References: <cover.1496256722.git.kafai@fb.com>
 <20170531192256.0e0d0ce1@cakuba.lan>
 <3f269312-efd4-86fc-e8e2-814af5898648@gmail.com>
 <6ab73989-6246-ba15-7178-7863a110165c@fb.com>
 <18d3c571-7434-eaea-43dc-d237712309d1@gmail.com>
 <cae83d5f-85ea-4c16-5f6b-2b71f0768b05@fb.com>
 <5e8b1713-0220-5c53-210d-8040efd36cfb@gmail.com>
 <affe7228-edf1-5307-2c0c-3ddb0cf247ae@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>, Jakub Kicinski <kubakici@wp.pl>,
        Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34487 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751126AbdFBLj7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 07:39:59 -0400
Received: by mail-it0-f67.google.com with SMTP id d68so10628769ita.1
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 04:39:59 -0700 (PDT)
In-Reply-To: <affe7228-edf1-5307-2c0c-3ddb0cf247ae@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/17 3:48 PM, Alexei Starovoitov wrote:
> You saw patch 7/8, right?

Apparently, not close enough. Nothing in the commit message mentioned
returning instructions. I skimmed the patch and filled in that GET_INFO
was returning just the meta-data.
