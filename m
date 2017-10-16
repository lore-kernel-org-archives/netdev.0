From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] tracing: bpf: Hide bpf trace events when they are not
 used
Date: Mon, 16 Oct 2017 16:01:25 -0400
Message-ID: <20171016160125.2a927a83@gandalf.local.home>
References: <20171012184002.0661a867@gandalf.local.home>
        <20171016.205434.1066116631088582472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016.205434.1066116631088582472.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Oct 2017 20:54:34 +0100 (WEST)
David Miller <davem@davemloft.net> wrote:

> Steven, I lost track of how this patch is being handled.
> 
> Do you want me to merge it via my net-next tree?

If you want. I could take it too if you give me an ack. It's not
dependent on any other changes so it doesn't matter which way it goes. I
know Alexei was thinking about doing the same for xdp but those appear
to be used even without BPF_SYSCALLS.

-- Steve
