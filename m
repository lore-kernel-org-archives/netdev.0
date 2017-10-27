From: David Howells <dhowells@redhat.com>
Subject: Timer breakage in net-next
Date: Fri, 27 Oct 2017 09:05:58 +0100
Message-ID: <22485.1509091558@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-ID: <22484.1509091558.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave, Kees,

Is it possible to get this timer fix:

	https://patchwork.ozlabs.org/patch/828333/

	timer: Provide wrappers safe for use with LOCKDEP

included in net-next?

You can add my Tested-by line.

David
