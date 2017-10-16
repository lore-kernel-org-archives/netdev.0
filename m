From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tracing: bpf: Hide bpf trace events when they are not
 used
Date: Mon, 16 Oct 2017 21:11:06 +0100 (WEST)
Message-ID: <20171016.211106.146432024027343504.davem@davemloft.net>
References: <20171012184002.0661a867@gandalf.local.home>
        <20171016.205434.1066116631088582472.davem@davemloft.net>
        <20171016160125.2a927a83@gandalf.local.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: rostedt@goodmis.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016160125.2a927a83@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>
Date: Mon, 16 Oct 2017 16:01:25 -0400

> On Mon, 16 Oct 2017 20:54:34 +0100 (WEST)
> David Miller <davem@davemloft.net> wrote:
> 
>> Steven, I lost track of how this patch is being handled.
>> 
>> Do you want me to merge it via my net-next tree?
> 
> If you want. I could take it too if you give me an ack. It's not
> dependent on any other changes so it doesn't matter which way it goes. I
> know Alexei was thinking about doing the same for xdp but those appear
> to be used even without BPF_SYSCALLS.

Ok, applied to my net-next tree and if you want to apply it to your's
too, here is the ACK:

Acked-by: David S. Miller <davem@davemloft.net>
