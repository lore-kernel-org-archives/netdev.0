From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/6] seccomp: make underlying bpf ref counted as well
Date: Fri, 4 Sep 2015 14:53:53 -0700
Message-ID: <CALCETrXLSx23y=rNiP79WJ54EWroWRcp39Pou4ERjZ5DnM5Ykg@mail.gmail.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com> <1441382664-17437-3-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441382664-17437-3-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> Additionally, we mark classic converted seccomp filters as seccomp eBPF
> programs, since they are a subset of what is supported in seccomp eBPF.

Off the top of my head, I'm okay with this.

--Andy
