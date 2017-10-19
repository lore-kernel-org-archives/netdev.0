From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: rxrpc: mark expected switch fall-throughs
Date: Thu, 19 Oct 2017 16:23:23 -0500
Message-ID: <20171019162323.Horde.9-ghoep6chyagc5A5TqQ8s8@gator4166.hostgator.com>
References: <20171019185016.GA18770@embeddedor.com>
 <32524.1508447816@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <32524.1508447816@warthog.procyon.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting David Howells <dhowells@redhat.com>:

> Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
>
>> +		/* fall through */
>
> All new comments in rxrpc should begin with a capital letter; I'm  
> switching to
> this as I modify the lines with comments on.  Fix checkpatch or gcc or
> whatever takes -Wimplicit-fallthrough to stop being silly.
>
>> -		/* Fall through */
>> -
>> +		/* fall through */
>
> No.  Firstly, it should be 'F'; secondly, don't remove the blank line - it's
> there for a reason.
>

What is the reason?

>> +		/* fall through */
>
> Capital 'F'.
>
>> -
>> +		/* fall through */
>
> Don't remove the blank line.  Capital 'F'.
>
>> +			/* fall through */
>
> Capital 'F'.
>
> David

Thanks
--
Gustavo A. R. Silva
