From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next 6/7] samples/bpf: Update cgrp2 socket tests
Date: Thu, 31 Aug 2017 18:40:25 -0700
Message-ID: <20170901014024.jgp37u2jdik56wu5@ast-mbp>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
 <1504217150-16151-7-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34545 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751109AbdIABk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 21:40:28 -0400
Received: by mail-pf0-f196.google.com with SMTP id v22so778546pfk.1
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 18:40:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504217150-16151-7-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 03:05:49PM -0700, David Ahern wrote:
> Update cgrp2 bpf sock tests to check that device, mark and priority
> can all be set on a socket via bpf programs attached to a cgroup.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
