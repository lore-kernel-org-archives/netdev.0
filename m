From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4] Make ipt_REJECT use icmp_send again
Date: Wed, 16 Mar 2005 14:44:24 -0800
Message-ID: <20050316144424.689d5981.davem@davemloft.net>
References: <20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050315100522.GA7275@gondor.apana.org.au>
	<20050315102450.0f3f1618.davem@davemloft.net>
	<42373142.6090902@trash.net>
	<20050315204006.GB22349@gondor.apana.org.au>
	<42374A35.6020308@trash.net>
	<20050316105100.GA8404@gondor.apana.org.au>
	<42388263.3090602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42388263.3090602@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Mar 2005 20:00:51 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Herbert Xu wrote:
> > I compared the two functions line-by-line to make sure that there
> > weren't any subtle differences.  Please double check this in case
> > I overlooked something important.
> 
> I double checked, all looks good to me.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks guys.
