From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: netdev-2.6 queue updated
Date: Thu, 27 Jan 2005 21:31:03 -0500
Message-ID: <41F9A3E7.5060607@pobox.com>
References: <41F980A0.8020905@pobox.com> <20050128021530.GB19150@hexapodia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>, Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Isaacson <adi@hexapodia.org>
In-Reply-To: <20050128021530.GB19150@hexapodia.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Isaacson wrote:
> On Thu, Jan 27, 2005 at 07:00:32PM -0500, Jeff Garzik wrote:
> 
>>The attached changelog describes what I just pushed out to BitKeeper 
>>(and what should be appearing in the next -mm release from Andrew).
>>
>>Note to BK users:  please re-clone netdev-2.6, don't just 'bk pull'.
> 
> 
> It's much more efficient to do
> % bk undo -a`bk repogca`


Well, by "re-clone" I mean recreate.  It's probably better to do what I 
do, clone the latest linux-2.5 repo and the pull netdev-2.6 into that. 
Far less messy than 'bk undo'.

	Jeff
