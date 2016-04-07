From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been left enabled.
Date: Thu, 07 Apr 2016 20:45:08 +0100
Message-ID: <1091.1460058308@warthog.procyon.org.uk>
References: <20160407.133843.156901424652264502.davem@davemloft.net> <20160407162256.21283.47849.stgit@warthog.procyon.org.uk> <20160407162309.21283.11482.stgit@warthog.procyon.org.uk> <1460046677.6715.95.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, joe@perches.com,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407.133843.156901424652264502.davem@davemloft.net>
Content-ID: <1090.1460058308.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> Yeah this custom stuff is really inappropriate given the excellent
> infrastructure we have these days...

Excellent only if I can get at it to find out why the something went wrong.
If it's lost because the machine panics, then it is worthless.

David
