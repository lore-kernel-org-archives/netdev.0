From: Willy Tarreau <w@1wt.eu>
Subject: Re: in kernel 2.6.x, tun/tap nic supports vlan packets
Date: Thu, 17 Apr 2014 16:23:48 +0200
Message-ID: <20140417142348.GD12562@1wt.eu>
References: <534F4C1E.1000006@gmail.com> <534FDCA9.4080005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	joe@perches.com, julia.lawall@lip6.fr, dingtianhong@huawei.com,
	linux-kernel@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:7527 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbaDQOYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2014 10:24:12 -0400
Content-Disposition: inline
In-Reply-To: <534FDCA9.4080005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 17, 2014 at 09:52:41PM +0800, zhuyj wrote:
> Although the maintainer will not merge these 2 patches, I still fix the 
> mistakes in these 2 patches. Now the latest patches are in attachment. 

Just for the record, I didn't say I "will not" merge them but that I will
not "without an Acked-by from some netdev people who are willing to help
in case of any future regression, which is unlikely but still possible".

That means that if you find someone here to vouch for your patches, I'll
gladly merge them into 2.6.32.x, otherwise not.

> Maybe these patches can help others.
> 
> The latest patches fix mistakes in rx stats.
> 
> Best Regards!
> Zhu Yanjun

Thanks,
Willy
