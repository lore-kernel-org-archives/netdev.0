From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Wed, 7 Oct 2015 23:30:26 -0700
Message-ID: <56160D82.5060405@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <5612F639.2050305@iogearbox.net> <56131B1F.80002@plumgrid.com>
 <5613C261.4080302@iogearbox.net> <56158CAF.9030209@plumgrid.com>
 <561597A6.4000203@iogearbox.net>
 <CAGXu5jLM5Wp_PjdcEcxUo-VoEmsSycF236MZaJd2wvLjbQx+eQ@mail.gmail.com>
 <5615AF92.50402@plumgrid.com> <20151008062155.GA18452@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151008062155.GA18452@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/7/15 11:21 PM, Ingo Molnar wrote:
> so I see no reason why unprivileged eBPF couldn't have a sysctl too - with the
> default value set to permissive.

agreed. sent out v2 follows 'modules_disabled' style.
