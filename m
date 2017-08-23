From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/8] bpf: Add mark and priority to sock options
 that can be set
Date: Tue, 22 Aug 2017 18:41:13 -0700
Message-ID: <20170823014111.gbmi3sypxav3fwn4@ast-mbp>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
 <1503447621-27997-3-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38234 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752822AbdHWBlP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 21:41:15 -0400
Received: by mail-pf0-f196.google.com with SMTP id h75so314065pfh.5
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 18:41:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503447621-27997-3-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 05:20:15PM -0700, David Ahern wrote:
> Add socket mark and priority to fields that can be set by
> ebpf program when a socket is created.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

lgtm
Acked-by: Alexei Starovoitov <ast@kernel.org>
