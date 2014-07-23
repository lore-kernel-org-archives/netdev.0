From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH RFC v2 net-next 02/16] bpf: update MAINTAINERS entry
Date: Wed, 23 Jul 2014 10:37:40 -0700
Message-ID: <CAGXu5j+mGDEPx5rCdVXzAdxR9SwQQ4ERM-Brxt4TmmncdPjzzg@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
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
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405657206-12060-3-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 9:19 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  MAINTAINERS |    7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ae8cd00215b2..32e24ff46da3 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1912,6 +1912,13 @@ S:       Supported
>  F:     drivers/net/bonding/
>  F:     include/uapi/linux/if_bonding.h
>
> +BPF (Safe dynamic programs and tools)

bikeshed: I feel like this shouldn't be an acronym. Maybe instead:

BERKELEY PACKET FILTER (BPF: Safe dynamic programs and tools)

-Kees

> +M:     Alexei Starovoitov <ast@kernel.org>
> +L:     netdev@vger.kernel.org
> +L:     linux-kernel@vger.kernel.org
> +S:     Supported
> +F:     kernel/bpf/
> +
>  BROADCOM B44 10/100 ETHERNET DRIVER
>  M:     Gary Zambrano <zambrano@broadcom.com>
>  L:     netdev@vger.kernel.org
> --
> 1.7.9.5
>



-- 
Kees Cook
Chrome OS Security
