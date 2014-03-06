From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] AF_RXRPC fixes and development [ver #2]
Date: Thu, 06 Mar 2014 17:16:56 -0500 (EST)
Message-ID: <20140306.171656.1597596195712774395.davem@davemloft.net>
References: <20140306.143719.2217501178599478723.davem@davemloft.net>
	<20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
	<8007.1394144113@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8007.1394144113@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 06 Mar 2014 22:15:13 +0000

> David Miller <davem@davemloft.net> wrote:
> 
>> > Here are some AF_RXRPC fixes (to tag rxrpc-20140226):
>>  ...
>> > And development patches (to tag rxrpc-devel-20140304):
>> 
>> A mix of both bug fixes and new features....
> 
> I did ask whether you wanted them in one or preferred them separate...

It depends upon whether you want the bug fixes to go into Linus's
tree for the current release or not.

If you do, submit just the bug fixes against 'net'

Then when I next merge 'net' into 'net-next', submit the feature
patches.
