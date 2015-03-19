From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v7 tip 5/8] samples: bpf: simple non-portable kprobe filter
 example
Date: Thu, 19 Mar 2015 08:53:07 -0700
Message-ID: <550AF0E3.1060406@plumgrid.com>
References: <1426542584-9406-1-git-send-email-ast@plumgrid.com>	<1426542584-9406-6-git-send-email-ast@plumgrid.com> <20150319115055.70e98cb8@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36753 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbbCSPxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 11:53:07 -0400
Received: by igbud6 with SMTP id ud6so28181177igb.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 08:53:06 -0700 (PDT)
In-Reply-To: <20150319115055.70e98cb8@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/19/15 8:50 AM, Steven Rostedt wrote:
>
> I'm not going to review the sample code, as I'm a bit strapped for
> time, and that's more userspace oriented anyway. I'm much more concerned
> that the kernel modifications are correct.

sure. thanks a lot for thorough review!
