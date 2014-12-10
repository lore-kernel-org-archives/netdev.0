From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: introduce helper macro for_each_cmsghdr
Date: Tue, 09 Dec 2014 22:56:23 -0800
Message-ID: <1418194583.1047.8.camel@perches.com>
References: <5487DBD9.1010908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5487DBD9.1010908@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-12-10 at 13:36 +0800, Gu Zheng wrote:
> Introduce helper macro for_each_cmsghdr as a wrapper of the enumerating
> cmsghdr from msghdr, just cleanup. 

This looks nicer.
Ideally this would have used: [PATCH V3] as the subject

> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> ---
> v2: use the lower-case macro name as Joe suggested.

And a description of the v2->v3 change here.
