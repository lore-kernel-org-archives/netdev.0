From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [PATCH] IPv6 IPSEC support
Date: Sat, 22 Feb 2003 21:15:26 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030222211526.2884077a.kazunori@miyazawa.org>
References: <20030222202623.38d41d8a.kazunori@miyazawa.org>
	<20030222.031326.103246837.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org, kunihiro@ipinfusion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030222.031326.103246837.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Feb 2003 03:13:26 -0800 (PST)
"David S. Miller" <davem@redhat.com> wrote:

>    From: Kazunori Miyazawa <kazunori@miyazawa.org>
>    Date: Sat, 22 Feb 2003 20:26:23 +0900
> 
>    I also moved the functions for ah, and esp.
> 
> I don't think this is so good idea...
>    
>    As a result of moving IPv6 IPsec functions to net/ipv4, it currently prevents to
>    make IPv6 as a module.
>    
> This is one of the reasons why ah/esp ipv6 should stay under ipv6.
> 

I will fix them and submit patch again.

Thank you,

--Kazunori Miyazawa (Yokogawa Electric Coporation)
