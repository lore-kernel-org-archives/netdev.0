From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_conntrack_h323: Remove typedef struct
Date: Tue, 24 Oct 2017 18:02:24 +0200
Message-ID: <20171024160224.GA12080@salvia>
References: <20171012225357.5144-1-harshasharmaiitr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Harsha Sharma <harshasharmaiitr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171012225357.5144-1-harshasharmaiitr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 13, 2017 at 04:23:57AM +0530, Harsha Sharma wrote:
> Remove typedef from struct as linux-kernel coding style tends to
> avoid using typedefs.
> Done using following coccinelle semantic patch

Applied, thanks Harsha.
