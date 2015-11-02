From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: convert hashtab lock to raw lock
Date: Mon, 02 Nov 2015 18:28:58 +0100
Message-ID: <56379D5A.7080402@iogearbox.net>
References: <1446243386-26582-1-git-send-email-yang.shi@linaro.org>	<20151031000356.GA28070@Alexeis-MacBook-Pro.local> <20151031094736.494427d7@grimm.local.home> <56350A86.5090500@iogearbox.net> <5637997D.1020502@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org
To: "Shi, Yang" <yang.shi@linaro.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5637997D.1020502@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/2015 06:12 PM, Shi, Yang wrote:
...
> If you think such info is necessary, I definitely could add it into the commit log in v2.

As this is going to be documented anyway (thanks! ;)), and the discussion
to this patch can be found in the archives for those wondering, I'm good:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks for the fix, Yang!

I presume this should go to net-next then ...
