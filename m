From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: how to report network device errors to userspace?
Date: Wed, 19 Jun 2002 17:50:28 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D10FCA4.4CDD78E9@nortelnetworks.com>
References: <Pine.LNX.4.33.0206191616060.1669-100000@presario> <3D10F552.C05ADD53@nortelnetworks.com> <20020619233659.A7368@wotan.suse.de> <m34rfzq6wb.fsf@trained-monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, Donald Becker <becker@scyld.com>,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>
List-Id: netdev.vger.kernel.org

Jes Sorensen wrote:

> Hmmm, the broader issue here is that we should aim for a generic
> interface - if netlink is the way, maybe it would be worth documenting
> it and moving towards getting it into more/all drivers.

I agree with this.

Also, if we're going to make it generic, lets plan on using it for stuff other
than just ethernet--I'd like to have it available for atm/sonet cards as well.

Chris


-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
