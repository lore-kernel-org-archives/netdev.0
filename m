From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: filter: fix upper BPF instruction limit
Date: Fri, 20 Jun 2014 23:00:30 +0200
Message-ID: <53A4A0EE.30804@redhat.com>
References: <20140618223457.GA31568@www.outflux.net> <CAMEtUuzbPExM5dT+xDqbHtV5LZ3+E2Q0eq4xdmKWzLOZbTmuUQ@mail.gmail.com> <CAGXu5jLYZ0jrFhd54aUhooLBWBUT28TQTLb41G107s=4U7ZxqA@mail.gmail.com> <CAMEtUuwPug7Bbgi2ccOx4jxd2Q80AnVoiHeeBW2av=_sQMiSfg@mail.gmail.com> <CAGXu5j+ZW9f8gW71_r5gRsEZoO_2fC3F4YXh_J1CwxRY6Vfx1Q@mail.gmail.com> <53A40948.5020201@redhat.com> <CAGXu5jLk_LDZ1-ou0iPNvAb2QHJdX-xhGRtyov-YZsmUOVo0GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Chema Gonzalez <chema@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jLk_LDZ1-ou0iPNvAb2QHJdX-xhGRtyov-YZsmUOVo0GA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/20/2014 06:48 PM, Kees Cook wrote:
...
>> Are there any plans to put and extend test cases from [1] via user space
>> side into the kernel self-test directory, i.e. into something like
>> tools/testing/selftests/seccomp/ so that in future new tests can be added
>> or run from there? Might be worth to consider.
>
> Yeah, I have this on my TODO list, but we need to juggle relicensing
> the test suite (it is currently BSD, not GPLv2). I'll keep chasing
> this.

Sounds good, please keep us in the loop.

Thanks,

Daniel
