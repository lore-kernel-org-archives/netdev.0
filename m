From: jamal <hadi@cyberus.ca>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 09:10:05 -0500
Message-ID: <1108995005.1091.165.camel@jzny.localdomain>
References: <4216B62D.6000502@pobox.com>  <4219E930.9080802@draigBrady.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <4219E930.9080802@draigBrady.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-21 at 08:59, P@draigBrady.com wrote:
> Jeff Garzik wrote:
> > 
> > http://www.theregister.co.uk/2005/02/18/intel_tcpip_attack/
> 
> I wonder is this ETA in conjunction with multicore CPUs?
> http://www.hoti.org/archive/Hoti11_program/papers/hoti11_11_regnier_g.pdf

I have a feeling ETA is one of the things behind theregister announce.
If you ask my opinion, its not a very smart idea. Now they have to write
a speacial stack just to sit in this one XEON processor they have while
the other(s) run Linux. They will not get 3x what Linux can today for a
simple app as L3 packet forwarding for example. And when it gets to
actually providing the features linux provides, they will be either at
the same speed or even worse depending on where they started. 
Broadcom btw is preaching the same angle.

What intel needs to do is kill its chipset division ;->

cheers,
jamal
