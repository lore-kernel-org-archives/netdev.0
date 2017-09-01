From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next 4/7] samples/bpf: Add detach option to
 test_cgrp2_sock
Date: Thu, 31 Aug 2017 18:39:04 -0700
Message-ID: <20170901013903.hhdmf44vtpykejhh@ast-mbp>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
 <1504217150-16151-5-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38349 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdIABjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 21:39:07 -0400
Received: by mail-pg0-f68.google.com with SMTP id t3so790962pgt.5
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 18:39:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504217150-16151-5-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 03:05:47PM -0700, David Ahern wrote:
> Add option to detach programs from a cgroup.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
