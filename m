From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v3 PATCH 9/9] rhashtable: Add immediate rehash during insertion
Date: Tue, 24 Mar 2015 09:15:44 +1100
Message-ID: <20150323221544.GA20231@gondor.apana.org.au>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <E1Ya2kO-0004JD-Om@gondolin.me.apana.org.au>
 <20150323165033.GD20752@casper.infradead.org>
 <20150323214422.GA19938@gondor.apana.org.au>
 <20150323215632.GA22099@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47941 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbbCWWQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:16:00 -0400
Content-Disposition: inline
In-Reply-To: <20150323215632.GA22099@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 09:56:32PM +0000, Thomas Graf wrote:
>
> OK. I can certinaly live with this. You are certinaly right that
> simplicity isn't a bad move here. Thanks for being patience and
> answering all the questions.
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Thank you for your reviewing and critiques!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
