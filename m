From: "David S. Miller" <davem@redhat.com>
Subject: Re: [XFRM] Convert XFRM_MSG_* macros to an enum
Date: Mon, 5 Jul 2004 16:47:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705164714.5aac5b62.davem@redhat.com>
References: <20040703095215.GA16195@gondor.apana.org.au>
	<20040705161148.503722e7.davem@redhat.com>
	<20040705232141.GA9939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040705232141.GA9939@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 09:21:41 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The point is that with enums we won't have to change XFRM_MSG_MAX
> every time a new message type is added.

Ok, applied.
