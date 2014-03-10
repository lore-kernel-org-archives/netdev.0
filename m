From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [GIT PULL] namespaces fixes for 3.14-rcX
Date: Mon, 10 Mar 2014 12:56:06 -0700
Message-ID: <87r469rfop.fsf@xmission.com>
References: <874n3ir0uw.fsf_-_@xmission.com> <87mwhaplo4.fsf_-_@xmission.com>
	<20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	<20140304.165122.445822929490466603.davem@davemloft.net>
	<87mwh5d1tf.fsf@xmission.com>
	<20140304145037.d46ee775d293dd1ad60aa8e3@linux-foundation.org>
	<87bnxesqf0.fsf_-_@xmission.com> <1394459944.17193.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, rgb@redhat.com,
	linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394459944.17193.12.camel@localhost> (Eric Paris's message of
	"Mon, 10 Mar 2014 09:59:04 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Paris <eparis@redhat.com> writes:

> On Sun, 2014-03-09 at 20:06 -0700, Eric W. Biederman wrote:
>> My efforts to get these fixes noticed by people who care about audit
>> seem to have landed on deaf ears, so since these are namespace related I
>> have put them in my tree.
>
> This commentary sounds like a pile of crap seeing as how there was a
> whole discussion around how to handle this stuff, which you were a part
> of.  And that the audit tree already picked up these 2 patches.

My apologies for offending.  Last night when I looked the audit tree had
not been updated in 7 weeks, and Andrew Morton wasn't ready to push
these fixes to Linus and was looking for someone who would.  Keeping
important bug fixes in my retransmit queue leaves me very grumpy.

> In any case, since I haven't sent them to Linus and I'm glad that is
> done, so feel free to consider this me Acking the pull request.

Eric
