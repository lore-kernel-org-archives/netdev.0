From: Oskar Andreasson <blueflux@koffein.net>
Subject: Re: [PATCH][RESEND] Update of tcp_syncookies explanation
Date: Tue, 1 Apr 2003 21:59:05 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304012156390.22941-100000@laptop1.agatha>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

Thanks for the reply! It was much appreciated, and I will do what I can to 
iron any problems out. (Also, I am very sorry for putting you or anyone 
else out there)

My final question is this... could you give any tip on what specifics to 
look/search for? I've been searching through the archives available at 
http://oss.sgi.com/projects/netdev/archive/ for every single inclusion of 
SYN in any of the archives by now, but could not find any specifics on 
_what_ the syn cookies breaks, or why, except for ECN, SACK and 
timestamps:/. 

I have also checked through the source code as well as I could, as well as
Mr. Bernsteins algorithms, searched the net at large with 3 search 
engines... and I am still not clever enough to figure it out.

In short, what I am trying to ask for is simply some kind of hints on
where to look... I hope you don't mind. 

Thanks!

PS. David, sorry for sending this in private before, no bad intentions 
meant. DS.

On Tue, 1 Apr 2003, David S. Miller wrote:

>    From: Oskar Andreasson <blueflux@koffein.net>
>    Date: Tue, 1 Apr 2003 19:33:13 +0200 (CEST)
> 
>    If anyone has any objections against this patch, please tell me so, with 
>    an explanation of why! 
>    
> You didn't explain how TCP syncookies "seriously violates the TCP
> protocol" yet you choose to remove that statement written by Alexey.
> 
> Either retain Alexey's statement (because it's true) or replace it
> with proper text.
> 
> I'm not going into the details of how syncookies violates the TCP
> protocol here, that has been hashed out many times on netdev and
> linux-net years in the past, so I direct people to search up such
> discussions instead of starting up yet another flame war here about
> the topic.  Thanks.
> 
> 
> 

-- 
----
Oskar Andreasson
http://www.frozentux.net
http://iptables-tutorial.frozentux.net
http://ipsysctl-tutorial.frozentux.net
mailto:blueflux@koffein.net
