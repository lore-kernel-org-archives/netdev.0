From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 27 Jul 2003 21:39:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030727213956.6ede8008.davem@redhat.com>
References: <20030727175557.1d624b36.davem@redhat.com>
	<Pine.LNX.4.44.0307272133140.24695-100000@dlang.diginsite.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: carlosev@newipnet.com, bloemsaa@xs4all.nl, marcelo@conectiva.com.br,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Lang <david.lang@digitalinsight.com>
In-Reply-To: <Pine.LNX.4.44.0307272133140.24695-100000@dlang.diginsite.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sun, 27 Jul 2003 21:37:10 -0700 (PDT)
David Lang <david.lang@digitalinsight.com> wrote:

> P.S. there are standards that are written documents and there are
> standards that are 'how everyone does it' for the most part Linux follows
> both types of standards, in this case the network team has decided to
> ignore the 'how everyone else does it' standards becouse there is nothing
> in a written standard that they are violating

Keep in mind that we implemented sys_sendfile() with different
arguments and semantics than everyone else.
