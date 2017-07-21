From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] rxrpc: Expose UAPI definitions to userspace
Date: Fri, 21 Jul 2017 12:07:20 -0700
Message-ID: <1500664040.14415.33.camel@perches.com>
References: <150066178283.18902.5185801865257802317.stgit@warthog.procyon.org.uk>
         <150066178969.18902.18414855274319475080.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150066178969.18902.18414855274319475080.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-07-21 at 19:29 +0100, David Howells wrote:
> Move UAPI definitions from the internal header and place them in a UAPI
> header file so that userspace can make use of them.

Please use git format-patch -M to make the rename clearer.
