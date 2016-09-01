From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: Don't expose skbs to in-kernel users
Date: Thu, 01 Sep 2016 16:38:32 -0700 (PDT)
Message-ID: <20160901.163832.1923741041602397930.davem@davemloft.net>
References: <147257235268.6716.12062621584578937716.stgit@warthog.procyon.org.uk>
        <147257235952.6716.3613899854387213654.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257235952.6716.3613899854387213654.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 30 Aug 2016 16:52:39 +0100

> Don't expose skbs to in-kernel users, such as the AFS filesystem, but
> instead provide a notification hook the indicates that a call needs
> attention and another that indicates that there's a new call to be
> collected.
 ...
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
