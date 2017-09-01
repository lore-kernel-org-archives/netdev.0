From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next 5/7] samples/bpf: Add option to dump socket
 settings
Date: Thu, 31 Aug 2017 18:39:30 -0700
Message-ID: <20170901013929.7k2qwkqmrb32nzys@ast-mbp>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
 <1504217150-16151-6-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35562 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbdIABjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 21:39:33 -0400
Received: by mail-pg0-f66.google.com with SMTP id r133so807368pgr.2
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 18:39:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504217150-16151-6-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 03:05:48PM -0700, David Ahern wrote:
> Add option to dump socket settings. Will be used in the next patch
> to verify bpf programs are correctly setting mark, priority and
> device based on the cgroup attachment for the program run.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
