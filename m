From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in
 prefix length
Date: Sat, 05 Mar 2005 02:28:43 +0100
Message-ID: <42290B4B.6080300@trash.net>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au> <20050305002910.GJ31837@postel.suug.ch> <42290172.7020403@trash.net> <20050305010319.GB27804@gondor.apana.org.au> <42290738.6050605@trash.net> <20050305012049.GL31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050305012049.GL31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> This will change the behaviour and makes my work completely useless.
> 
> Assuming one adds 1.1.1.1/24, 1.1.1.2/24 and then deletes 1.1.1.2/24
> one would expect 1.1.1.2/24 to be deleted but that wouldn't be the
> case.

True, that would be pretty stupid :)

Regards
Patrick
