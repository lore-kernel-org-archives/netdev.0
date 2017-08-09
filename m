From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Wed, 09 Aug 2017 22:34:17 +0200
Message-ID: <598B71C9.7090303@iogearbox.net>
References: <59897A7C.10009@iogearbox.net> <20170808.094857.245786887664041622.davem@davemloft.net> <650EB3B0-1101-4624-905A-E68D2EC5920F@imgtec.com> <20170808.145433.1287676484744976417.davem@davemloft.net> <20170809073926.GO6973@jhogan-linux.le.imgtec.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, linux-kernel@vger.kernel.org, rostedt@goodmis.org,
        mingo@redhat.com, netdev@vger.kernel.org
To: James Hogan <james.hogan@imgtec.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809073926.GO6973@jhogan-linux.le.imgtec.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2017 09:39 AM, James Hogan wrote:
[...]
> time (but please consider looking at the other patch which is certainly
> a more real issue).

Sorry for the delay, started looking into that and whether we
have some other options, I'll get back to you on this.

Thanks,
Daniel
