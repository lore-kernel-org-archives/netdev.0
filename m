From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v6 0/5] bpf: security: New file mode and LSM
 hooks for eBPF object permission control
Date: Thu, 19 Oct 2017 11:48:33 +0200
Message-ID: <59E874F1.6040609@iogearbox.net>
References: <20171016191135.8046-1-chenbofeng.kernel@gmail.com> <20171018.134729.837318478487425125.davem@davemloft.net> <alpine.LFD.2.20.1710191248100.1108@t440.gateway.2wire.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chenbofeng.kernel@gmail.com, netdev@vger.kernel.org,
        Selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
        jeffv@google.com, alexei.starovoitov@gmail.com, lorenzo@google.com,
        sds@tycho.nsa.gov, paul@paul-moore.com, fengc@google.com
To: James Morris <james.l.morris@oracle.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1710191248100.1108@t440.gateway.2wire.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2017 03:49 AM, James Morris wrote:
> On Wed, 18 Oct 2017, David Miller wrote:
>
>> Series applied.
>
> I hadn't gotten to reviewing this patchset yet.
>
> Please wait for more acks/reviews from LSM folk for things touching
> security/, next time.

It didn't get applied yet due to a build error, v7 is pending here
if you want to take a look (the series is already on the lists with
multiple feedback rounds since beginning of Oct):

   http://patchwork.ozlabs.org/project/netdev/list/?series=8967

Thanks,
Daniel
