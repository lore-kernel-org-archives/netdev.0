From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: reduce stack usage
Date: Wed, 23 Feb 2005 20:31:40 -0800
Message-ID: <20050223203140.4bc3994a.davem@davemloft.net>
References: <20050218134219.3f079110.rddunlap@osdl.org>
	<20050218221121.GA22845@electric-eye.fr.zoreil.com>
	<42166E3F.2050304@osdl.org>
	<16921.60572.951532.31861@robur.slu.se>
	<421A0880.5070205@osdl.org>
	<16923.21163.112945.608974@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, Robert.Olsson@data.slu.se, romieu@fr.zoreil.com,
        netdev@oss.sgi.com
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16923.21163.112945.608974@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Feb 2005 16:41:31 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> Randy.Dunlap writes:
>  > >  Here is version with just one buffer.
>  > 
>  > Yep, even better:  few changes + using sizeof.
> 
>  Hello.
> 
>  OK! Then we ask DaveM to apply the patch.

Applied, thanks guys.
