From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 13:07:49 +1100
Message-ID: <20050125020749.GA16809@gondor.apana.org.au>
References: <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch> <20050124225423.GA15405@gondor.apana.org.au> <20050124234515.GA31837@postel.suug.ch> <20050125000759.GA15883@gondor.apana.org.au> <20050124164049.3b939791.davem@davemloft.net> <20050125014538.GB31837@postel.suug.ch> <20050125014838.GA16637@gondor.apana.org.au> <41F5A7F8.6060706@davidcoulson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Coulson <david@davidcoulson.net>
Content-Disposition: inline
In-Reply-To: <41F5A7F8.6060706@davidcoulson.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 24, 2005 at 08:59:20PM -0500, David Coulson wrote:
> 
> I've got the NIC VLANed out in the kernel. It's the same physical NIC 
> for inside and outside.

I don't think the vlan code actually sets the features bits...
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
