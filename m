From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH][BLUETOOTH] kill bt_sock_alloc
Date: Wed, 09 Mar 2005 09:35:37 -0800
Message-ID: <422F33E9.4030401@qualcomm.com>
References: <20050308094937.GA9468@conectiva.com.br> <20050308095209.GB9468@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, davem@davemloft.net, netdev@oss.sgi.com
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20050308095209.GB9468@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Tue, Mar 08, 2005 at 06:49:37AM -0300, Arnaldo Carvalho de Melo escreveu:
> 
>>Hi,
>>
>>	Please take a look and if acceptable pull from:
>>
>>bk://kernel.bkbits.net/acme/connection_sock-2.6
> 
> 
> Sorry, now with the patch attached.

Looks good to me. Marcel I'd suggest for you to apply this patch.
It helps in reducing overall size of the socket structures.

Thanks
Max
