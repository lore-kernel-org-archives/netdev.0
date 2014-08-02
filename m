From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 5/5] net: filter: split 'struct sk_filter'
 into socket and bpf parts
Date: Sat, 02 Aug 2014 15:10:24 -0700 (PDT)
Message-ID: <20140802.151024.636036304502082388.davem@davemloft.net>
References: <CAMEtUuympZm+qVOc+4MJoSnAwSZ-Gx=tSOaHwudtP7Q92eHAtw@mail.gmail.com>
	<20140801190341.GA28642@salvia>
	<CAMEtUuxDSGysNKr12qYQAXjmb4qP45trh3qVx41W7WVduPS5zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, dborkman@redhat.com, willemb@google.com,
	keescook@chromium.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuxDSGysNKr12qYQAXjmb4qP45trh3qVx41W7WVduPS5zw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 1 Aug 2014 12:12:36 -0700

> Dave, this patch has trivial conflict with Daniel's
> ("team: fix releasing uninitialized pointer to BPF prog") fix.
> Let me know if you want me to respin the series or you'll patch up
> the conflict yourself.

I took care of this, it was easy to resolve.

Thanks.
