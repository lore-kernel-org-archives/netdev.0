From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next 3/7] samples/bpf: Update sock test to allow
 setting mark and priority
Date: Thu, 31 Aug 2017 18:38:33 -0700
Message-ID: <20170901013831.2j2n73zvk36dk44j@ast-mbp>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
 <1504217150-16151-4-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:37000 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdIABig (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 21:38:36 -0400
Received: by mail-pg0-f52.google.com with SMTP id 83so3788853pgb.4
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 18:38:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504217150-16151-4-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 03:05:46PM -0700, David Ahern wrote:
> Update sock test to set mark and priority on socket create.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
