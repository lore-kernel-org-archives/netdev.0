From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Tue, 25 Nov 2014 14:04:41 -0500 (EST)
Message-ID: <20141125.140441.401150380839514113.davem@davemloft.net>
References: <5474ABB6.3030400@infradead.org>
	<20141125.121305.2094097848188324942.davem@davemloft.net>
	<20141125185310.GA24891@cloud>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@infradead.org, pieter@boesman.nl,
	alexander.h.duyck@intel.com, viro@zeniv.linux.org.uk,
	ast@plumgrid.com, akpm@linux-foundation.org, beber@meleeweb.net,
	catalina.mocanu@gmail.com, dborkman@redhat.com,
	edumazet@google.com, ebiederm@xmission.com, fabf@skynet.be,
	fuse-devel@lists.sourceforge.net, geert@linux-m68k.org,
	hughd@google.com, iulia.manda21@gmail.com, JBeulich@suse.com,
	bfields@fieldses.org, jlayton@poochiereds.net,
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	mcgrof@suse.com, mattst88@gmail.com, mgorman@suse.de,
	mst@redhat.com, miklos@szeredi.hu, netdev@vger.kernel.org,
	oleg@redhat.com, Paul.Durrant@citrix.com,
	paulmck@linux.vnet.ibm.com, pefoley2@pefoley.com, tgraf@suug.ch,
	therbert@google.com, trond.myklebust@primarydata.com,
	willemb@google.com, xiaoguangrong@linux.vnet.ibm.com,
	zhe
To: josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125185310.GA24891@cloud>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: josh@joshtriplett.org
Date: Tue, 25 Nov 2014 10:53:10 -0800

> It's not a "slippery slope"; it's been our standard practice for ages.

We've never put an entire class of generic system calls behind
a config option.
