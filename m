From: David Coulson <david@davidcoulson.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 09:49:12 -0500
Message-ID: <41F50AE8.1000800@davidcoulson.net>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124045635.GA30372@gondor.apana.org.au> <41F48293.9050301@trash.net> <20050124122247.GQ23931@postel.suug.ch> <41F4F37F.3070000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41F4F37F.3070000@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Patrick McHardy wrote:
> What about modules, .config, ... ?

No kernel module support on the box. Only non-standard patch, was the 
mppe/mppc patch which isn't being used right now (It's turned on in the 
kernel config however). I attached the .config to a previous e-mail.

David

-- 
David J. Coulson
email: david@davidcoulson.net
web: http://www.davidcoulson.net/
phone: (216) 920-3100 / (216) 258-4942
