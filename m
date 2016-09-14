From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 0/4] rxrpc: Support IPv6
Date: Wed, 14 Sep 2016 08:36:39 +0100
Message-ID: <25888.1473838599@warthog.procyon.org.uk>
References: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Content-ID: <25886.1473838599.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> wrote:

> Here is a set of patches that add IPv6 support.  They need to be applied on
> top of the just-posted miscellaneous fix patches.  They are:

This subset needs to be made to depend on CONFIG_IPV6.

David
