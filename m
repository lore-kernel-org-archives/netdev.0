From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rxrpc: Trim line-terminal whitespace [ver #2]
Date: Fri, 10 Jun 2016 10:50:17 -0700 (PDT)
Message-ID: <20160610.105017.125660401827751958.davem@davemloft.net>
References: <146556587905.17482.14686239628937102032.stgit@warthog.procyon.org.uk>
	<17756.1465566081@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17756.1465566081@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 10 Jun 2016 14:41:21 +0100

> Hi Dave,
> 
> Can you please add these two patches to net-next?
> 
> Thanks,
> David

David, please stop telling me which tree things go into this way.

There is a clear, documented, way to do this properly with your
patches themselves.  Put it in the Subject line:

	Subject: "[PATCH net-next 1/2] rxrpc: ..."

Also, you must provides a header introductory "[PATCH net-next 0/2] ..."
postings giving a high level overview of what the patch series is
about, what it is doing, why it is doing so, and how it is doing it.
