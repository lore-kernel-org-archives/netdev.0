From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 8/9] net: filter: rework/optimize internal
 BPF interpreter's instruction set
Date: Wed, 26 Mar 2014 12:22:26 -0400 (EDT)
Message-ID: <20140326.122226.1847173879330664246.davem@davemloft.net>
References: <53321E3B.8080709@linux.intel.com>
	<20140325.204628.1622839093852736075.davem@davemloft.net>
	<CAMEtUuyQs4Jk+zi9_DxFRnoTFGQ8WXn4aPPJ+yp5XxWb6pkmbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hpa@linux.intel.com, dborkman@redhat.com, netdev@vger.kernel.org,
	hagen@jauu.net, keescook@chromium.org, pmoore@redhat.com,
	mingo@kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyQs4Jk+zi9_DxFRnoTFGQ8WXn4aPPJ+yp5XxWb6pkmbQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 25 Mar 2014 18:58:14 -0700

> So I think we can debate backward jumps later when they actually
> will be up for review.

Then don't mention it in the commit message.
