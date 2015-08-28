From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: sched: don't break line in tc_classify loop
 notification
Date: Fri, 28 Aug 2015 10:00:35 -0700
Message-ID: <55E093B3.2030308@plumgrid.com>
References: <4b24d2566b1877613540f277e60673c817b71842.1440780286.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36090 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbbH1RAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 13:00:37 -0400
Received: by padhm10 with SMTP id hm10so12559244pad.3
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 10:00:37 -0700 (PDT)
In-Reply-To: <4b24d2566b1877613540f277e60673c817b71842.1440780286.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/28/15 9:46 AM, Daniel Borkmann wrote:
> Just some minor noise follow-up to address some stylistic issues of
> commit 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}").
> Accidentally v1 instead of v2 of that commit got applied, so this
> patch adds the relative diff.
>
> Suggested-by: Alexei Starovoitov<ast@plumgrid.com>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
