From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:50:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE49BA.6070401@us.ibm.com>
References: <3EEE28DE.6040808@us.ibm.com>	<3EEE40F1.4030107@us.ibm.com> <20030616.151308.55864910.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: janiceg@us.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   stekloff@us.ibm.com, girouard@us.ibm.com, lkessler@us.ibm.com,
   kenistonj@us.ibm.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030616.151308.55864910.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Nivedita Singhvi <niv@us.ibm.com>
>    Date: Mon, 16 Jun 2003 15:13:05 -0700
>    
>    I'd certainly like to see messages from the driver when the
>    card enters/leaves promiscuous mode,
> 
> egrep "promiscuous mode" net/core/dev.c | grep printk


Yeah, but dev_mc_upload() doesnt return any status ;).
(For those of us who distrust hw (Sorry Scott! :))).

But it was just my example, I assure you. I'm not
holding up a flag in the wind on this particular nit.
I do see positives in the feature as a whole though.
It would be a shame to get grounded for minor things..

thanks,
Nivedita
