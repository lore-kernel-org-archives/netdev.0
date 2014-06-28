From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC net-next 04/14] bpf: update MAINTAINERS entry
Date: Fri, 27 Jun 2014 17:18:08 -0700
Message-ID: <1403914688.9064.20.camel@joe-AO725>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	 <1403913966-4927-5-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403913966-4927-5-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add MAINTAINERS entry.

On Fri, 2014-06-27 at 17:05 -0700, Alexei Starovoitov wrote:
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -1881,6 +1881,15 @@ S:	Supported
>  F:	drivers/net/bonding/
>  F:	include/uapi/linux/if_bonding.h
>  
> +BPF

While a lot of people know what BPF is, I think it'd
be better to have something like

BPF - SOCKET FILTER (Berkeley Packet Filter like)
> +M:	Alexei Starovoitov <ast@plumgrid.com>
> +L:	netdev@vger.kernel.org
> +L:	linux-kernel@vger.kernel.org
> +S:	Supported
> +F:	kernel/bpf/
> +F:	include/uapi/linux/bpf.h
> +F:	include/linux/bpf.h
