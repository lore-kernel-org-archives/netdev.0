From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] LSM networking update: summary (0/5)
Date: Sat, 8 Feb 2003 20:43:55 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302082018220.10837-100000@blackbird.intercode.com.au>
References: <20030208.004440.91323755.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Makan.Pourzandi@ericsson.ca, <kuznet@ms2.inr.ac.ru>,
   <linux-security-module@wirex.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030208.004440.91323755.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 8 Feb 2003, David S. Miller wrote:

>    From: James Morris <jmorris@intercode.com.au>
>    Date: Sat, 8 Feb 2003 10:10:44 +1100 (EST)
>    
>    As mentioned during the last week, the current set of network hooks will
>    not directly support explicitly labeled networking.
> 
> Why not?  I thought we had completely established that anything
> the socket receive SKB hook could not handle would be implementable
> via netfilter.
> 

By not directly supported, I mean by the LSM network hooks.


- James
-- 
James Morris
<jmorris@intercode.com.au>
