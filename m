From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Intel and TOE in the news
Date: Sun, 20 Feb 2005 21:37:38 -0500
Message-ID: <42194972.8060303@pobox.com>
References: <200502210158.j1L1wcDD004318@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com
To: alex@neterion.com
In-Reply-To: <200502210158.j1L1wcDD004318@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alex Aizman wrote:
> Our experimental Linux driver already supports MSI and MSI-X (the latter not
> tested). Once/if multi-MSI support in Linux becomes available it'd be
> practically possible to scale TCP connections with a number of CPUs.
> Alternative: wait until Xframe II adapter w/MSI-X.. 


The infiniband Linux driver is already using multi-MSI.  You are behind 
the times :)

	Jeff
