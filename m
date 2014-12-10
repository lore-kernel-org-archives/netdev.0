From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: introduce helper macro for_each_cmsghdr
Date: Wed, 10 Dec 2014 06:51:46 -0800
Message-ID: <1418223106.18092.1.camel@perches.com>
References: <5487DBD9.1010908@cn.fujitsu.com>
	 <1418194583.1047.8.camel@perches.com> <54880124.8040509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54880124.8040509@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-12-10 at 16:15 +0800, Gu Zheng wrote:
> On 12/10/2014 02:56 PM, Joe Perches wrote:
> > On Wed, 2014-12-10 at 13:36 +0800, Gu Zheng wrote:
> >> Introduce helper macro for_each_cmsghdr as a wrapper of the enumerating
> >> cmsghdr from msghdr, just cleanup. 
> > 
> > This looks nicer.
> > Ideally this would have used: [PATCH V3] as the subject
> 
> The previous v2 thread was marked as mistake, so this is the really active
> v2 version.

A buggy submitted version is still a version.
Using an incremented version number helps.
