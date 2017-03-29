From: fche@redhat.com (Frank Ch. Eigler)
Subject: Re: [RFC PATCH tip/master 0/3] kprobes: tracing: kretprobe_instance dynamic allocation
Date: Wed, 29 Mar 2017 09:27:35 -0400
Message-ID: <y0ma884tdq0.fsf@fche.csb>
References: <149076484118.24574.7083269903420611708.stgit@devbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,  Ingo Molnar <mingo@redhat.com>,  Alban Crequy <alban.crequy@gmail.com>,  Alban Crequy <alban@kinvolk.io>,  Alexei Starovoitov <ast@kernel.org>,  Jonathan Corbet <corbet@lwn.net>,  Arnaldo Carvalho de Melo <acme@redhat.com>,  Omar Sandoval <osandov@fb.com>,  linux-doc@vger.kernel.org,  netdev@vger.kernel.org,  linux-kernel@vger.kernel.org,  iago@kinvolk.io,  michael@kinvolk.io,  Dorau Lukasz <lukasz.dorau@intel.com>,  systemtap@sourceware.org
To: Masami Hiramatsu <mhiramat@kernel.org>
Return-path: <systemtap-return-25242-gls-systemtap=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
In-Reply-To: <149076484118.24574.7083269903420611708.stgit@devbox> (Masami	Hiramatsu's message of "Wed, 29 Mar 2017 14:20:51 +0900")
List-Id: netdev.vger.kernel.org


mhiramat wrote:

> Here is a correction of patches to introduce kretprobe_instance
> dynamic allocation for avoiding kretprobe silently miss-hits.
> [...]

Thanks, this looks automatically useful also to systemtap users.

- FChE
