From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v8 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Sat, 30 Aug 2014 08:22:19 +0200
Message-ID: <54016D9B.5070905@redhat.com>
References: <1409171833-6979-1-git-send-email-ast@plumgrid.com> <1409171833-6979-3-git-send-email-ast@plumgrid.com> <5400BAB7.80001@redhat.com> <CAADnVQJbgiUK1vt_SDEG6Yee-Ht67e2M82PrHb3Kx533BOF-rg@mail.gmail.com> <5400FDA0.7000704@redhat.com> <CAMEtUuyRUujYhRsH9aUx0h7wvU1DrKRHNWZtoOYEgHVfKdCTxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyRUujYhRsH9aUx0h7wvU1DrKRHNWZtoOYEgHVfKdCTxw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/30/2014 01:01 AM, Alexei Starovoitov wrote:
...
> btw, I've spent last two days writing syscall manpage :(
> What is the best way to present it for review?
> If I just attach it raw, it's unreadable... I can include a link
> to html page, but man2html produces ugly pages comparing
> to what 'man' command shows. Any nice man converters
> that generate stuff seen on man7.org ?

What about :

   man foo > bar

And then copy that into your mail client?
