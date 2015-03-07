From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 tip 0/7] tracing: attach eBPF programs to kprobes
Date: Fri, 6 Mar 2015 20:09:38 -0500
Message-ID: <20150306200938.6a6387c0@gandalf.local.home>
References: <1425252465-27527-1-git-send-email-ast@plumgrid.com>
	<CAMEtUuzOQqyXgZaytwOPxAfn5ucu08HjAMrFUgeSaLRVg9E0rg@mail.gmail.com>
	<20150304203316.GA7142@gmail.com>
	<20150304154824.5f165c6d@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150304154824.5f165c6d@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Mar 2015 15:48:24 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Wed, 4 Mar 2015 21:33:16 +0100
> Ingo Molnar <mingo@kernel.org> wrote:
> 
> > 
> > * Alexei Starovoitov <ast@plumgrid.com> wrote:
> > 
> > > On Sun, Mar 1, 2015 at 3:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> > > > Peter, Steven,
> > > > I think this set addresses everything we've discussed.
> > > > Please review/ack. Thanks!
> > > 
> > > icmp echo request
> > 
> > I'd really like to have an Acked-by from Steve (propagated into the 
> > changelogs) before looking at applying these patches.
> 
> I'll have to look at this tomorrow. I'm a bit swamped with other things
> at the moment :-/
> 

Just an update. I started looking at it but then was pulled off to do
other things. I'll make this a priority next week. Sorry for the delay.

-- Steve
