From: jamal <hadi@cyberus.ca>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: Fri, 28 Feb 2003 08:33:48 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030228083009.Y53276@shell.cyberus.ca>
References: <3E5E7081.6020704@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, "" <netdev@oss.sgi.com>,
   "" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3E5E7081.6020704@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Thu, 27 Feb 2003, Chris Friesen wrote:

>
> It is fairly common to want to distribute information between a single
> sender and multiple receivers on a single box.
>
> Multicast IP sockets are one possibility, but then you have additional
> overhead in the IP stack.
>

I think this is a _very weak_  reason.
Without addressing any of your other arguements, can you describe what
such painful overhead you are talking about? Did you do any measurements
and under what circumstances are unix sockets vs say localhost bound
udp sockets are different? I am not looking for hand waving reason of
"but theres an IP stack".

cheers,
jamal
