From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [TG3] Initialise reset_task properly
Date: Wed, 12 Nov 2003 09:39:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB24629.4090302@pobox.com>
References: <20031112104833.GA15583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031112104833.GA15583@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi Jeff:
> 
> I've received a queue_work crash report due to reset_task in tg3 not being
> initialised correctly.  This patch should fix it.


Thanks, I'll send this to Linus/Marcelo today...

	Jeff
