From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 24 Mar 2015 11:59:15 -0400 (EDT)
Message-ID: <20150324.115915.829626973555093278.davem@davemloft.net>
References: <20150324134508.77b039a9@canb.auug.org.au>
	<20150323.230003.1242651745820752377.davem@davemloft.net>
	<20150324104346.GA7422@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	viro@ZenIV.linux.org.uk, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, tadeusz.struk@intel.com
To: hch@lst.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150324104346.GA7422@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Tue, 24 Mar 2015 11:43:46 +0100

> On Mon, Mar 23, 2015 at 11:00:03PM -0400, David Miller wrote:
>> Ok, more conflicts wiht Al's vfs work.
>> 
>> This is starting to pile on, heavily...
> 
> These are my changes.  But I think it would be much better if any aio-related
> changes like this one we be one on top of my changes in Al's iocb branch,
> there have been various changes, and it would be better to review and
> commit the changes on top of it instead of carrying the changes as fixups.
> 
> Nevermind the actual test coverage..

That's no longer possible as my tree never rebases and the commits are pushed
out already.

Another solution to this set of conflicts, is therefore necessary.
