From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/5] Networking cgroup controller
Date: Thu, 25 Aug 2016 12:11:13 -0400
Message-ID: <20160825161113.GD20479@htj.duckdns.org>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
 <20160824210357.GU8185@htj.duckdns.org>
 <CAF2d9jjXxjgJU1VWDERKkv4LRvmhpjpyx7Dx76egQx43aaXtmQ@mail.gmail.com>
 <20160825160920.GC20479@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, lizefan@huawei.com, hannes@cmpxchg.org,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
        linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, tom@herbertland.com
To: Mahesh Bandewar
         =?utf-8?B?KOCkruCkueClh+CktiDgpKzgpILgpKHgpYfgpLXgpL4=?=
         =?utf-8?B?4KSwKQ==?= <maheshb@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160825160920.GC20479@htj.duckdns.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 12:09:20PM -0400, Tejun Heo wrote:
> ebpf approach does have its shortcomings for sure but mending them
> seems a lot more manageable and future-proof than going with fixed but
> constantly expanding set of operations.  e.g. We can add per-cgroup
> bpf programs which are called only on socket creation or other major
> events, or just let bpf programs which get called on bind(2), and add
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	please ignore this part. half-assed edit.

-- 
tejun
