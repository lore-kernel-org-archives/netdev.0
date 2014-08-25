From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH V2 1/1] netfilter/jump_label: HAVE_JUMP_LABEL instead of
 CONFIG_JUMP_LABEL
Date: Mon, 25 Aug 2014 10:38:57 +0200
Message-ID: <20140825083857.GA10456@salvia>
References: <1408675215-2893-1-git-send-email-yizhouzhou@ict.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jbaron@akamai.com,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408675215-2893-1-git-send-email-yizhouzhou@ict.ac.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 22, 2014 at 10:40:15AM +0800, Zhouyi Zhou wrote:
> Use HAVE_JUMP_LABEL as elsewhere in the kernel to ensure
> that the toolchain has the required support in addition to
> CONFIG_JUMP_LABEL being set.

Applied, thanks.
