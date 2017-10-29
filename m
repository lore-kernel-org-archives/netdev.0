From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: bpftool: add bash completion for
 bpftool
Date: Sun, 29 Oct 2017 18:38:08 +0900 (KST)
Message-ID: <20171029.183808.2115606795396402323.davem@davemloft.net>
References: <20171026211605.25897-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        oss-drivers@netronome.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, quentin.monnet@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026211605.25897-1-jakub.kicinski@netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 26 Oct 2017 14:16:05 -0700

> From: Quentin Monnet <quentin.monnet@netronome.com>
> 
> Add a completion file for bash. The completion function runs bpftool
> when needed, making it smart enough to help users complete ids or tags
> for eBPF programs and maps currently on the system.
> 
> Update Makefile to install completion file to
> /usr/share/bash-completion/completions when running `make install`.
> 
> Emacs file mode and (at the end) Vim modeline have been added, to keep
> the style in use for most existing bash completion files. In this, it
> differs from tools/perf/perf-completion.sh, which seems to be the only
> other completion file among the kernel sources repository. This is also
> valid for indent style: 4-space indents, as in other completion files.
> 
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

I'll apply this for now.

If there are major objections I can revert.

Thanks.
