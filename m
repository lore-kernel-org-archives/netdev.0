From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v6 2/5] bpf: Add tests for eBPF file mode
Date: Tue, 17 Oct 2017 01:00:09 +0200
Message-ID: <59E539F9.7080404@iogearbox.net>
References: <20171016191135.8046-1-chenbofeng.kernel@gmail.com> <20171016191135.8046-3-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Stephen Smalley <sds@tycho.nsa.gov>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171016191135.8046-3-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2017 09:11 PM, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Two related tests are added into bpf selftest to test read only map and
> write only map. The tests verified the read only and write only flags
> are working on hash maps.
>
> Signed-off-by: Chenbo Feng <fengc@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
