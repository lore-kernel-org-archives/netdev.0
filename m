From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: how to report network device errors to userspace?
Date: Wed, 19 Jun 2002 17:44:05 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D10FB25.667421CB@nortelnetworks.com>
References: <Pine.LNX.4.33.0206191616060.1669-100000@presario> <3D10F552.C05ADD53@nortelnetworks.com> <20020619233659.A7368@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Donald Becker <becker@scyld.com>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> I would suggest sending a netlink message from the driver.  That's really
> what netlink was designed for.

Can you point me to a driver that's done this cleanly as an example to follow?

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
