From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][SELINUX] 1/2 sock_create_kern()
Date: Sat, 8 May 2004 15:01:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040508150117.4a88b81a.davem@redhat.com>
References: <Xine.LNX.4.44.0405071043540.21372-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sds@epoch.ncsc.mil, chrisw@osdl.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, selinux@tycho.nsa.gov
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0405071043540.21372-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 May 2004 11:05:10 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> The patch below adds a function sock_create_kern() for use when the kernel 
> creates sockets for its own use.

This looks fine, applied.
