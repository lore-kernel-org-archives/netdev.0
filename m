From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux v3 1/1] fs/proc: use a rb tree for the directory
 entries
Date: Tue, 14 Oct 2014 15:30:32 -0400 (EDT)
Message-ID: <20141014.153032.1779634723768373525.davem@davemloft.net>
References: <1412672559-5256-1-git-send-email-nicolas.dichtel@6wind.com>
	<1412672559-5256-2-git-send-email-nicolas.dichtel@6wind.com>
	<543BB42B.30505@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, akpm@linux-foundation.org,
	adobriyan@gmail.com, rui.xiang@huawei.com, viro@zeniv.linux.org.uk,
	oleg@redhat.com, gorcunov@openvz.org,
	kirill.shutemov@linux.intel.com, grant.likely@secretlab.ca,
	tytso@mit.edu, torvalds@linux-foundation.org
To: nicolas.dichtel@6wind.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <543BB42B.30505@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 13 Oct 2014 13:14:51 +0200

> I'm not sure who is in charge of taking this patch. Should I resend
> it to someone else or is it already included in a tree?

Just want to make it clear that I don't intend to take this via
the networking tree.
