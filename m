From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] af_packet: use void* for virtual addresses
Date: Fri, 27 Aug 2004 16:51:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040827165139.0061175a.davem@redhat.com>
References: <E1C0p77-0004Ik-00@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, haveblue@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <E1C0p77-0004Ik-00@kernel.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch works for me.

I hope people agree and fix up the page alloc/free return
types, because your change has basically currently just
moved the casts from one place to another :-)

Anyways, patch applied, thanks.
