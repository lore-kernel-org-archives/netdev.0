From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Fix off-by-one in max protocol-type check
Date: Sun, 30 May 2004 16:59:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040530165906.206167f5.davem@redhat.com>
References: <40B71A1C.5080400@trash.net>
	<40B71ABD.5060600@trash.net>
	<20040529123829.10778ffe.davem@redhat.com>
	<40BA7111.7030307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40BA7111.7030307@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 May 2004 01:41:05 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Judging from 2.4.27-pre4 changelog, you forgot to apply this
> patch to 2.4. Patch from 2.6 attached, it applies with some
> offset.

Good catch, applied to 2.4.x now too.

Thanks.
