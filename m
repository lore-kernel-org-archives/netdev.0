From: Chris Dukes <pakrat@www.uk.linux.org>
Subject: Re: TCP IP Offloading Interface
Date: Tue, 15 Jul 2003 20:36:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030715193647.GQ2686@parcelfarce.linux.theplanet.co.uk>
References: <E3738FB497C72449B0A81AEABE6E713C027A43@STXCHG1.simpletech.com> <Pine.LNX.4.51.0307151451160.4590@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jordi Ros <jros@xiran.com>, "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.51.0307151451160.4590@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 15, 2003 at 03:01:11PM -0400, Ralph Doncaster wrote:
> On Mon, 14 Jul 2003, Jordi Ros wrote:
> 
> > Note that Microsoft is considering TOE under its Scalable Networking Program. To keep linux competitive, I would encourage a healthy discussion on this matter. Again, TOE is not the goal but the means to deliver important technologies for the next generation of servers. This will be critical as the backbone of the Internet goes to all optical networks while the servers stay at the electronic domain. As shown by McKeown, "Circuit Switching in the Core", the line capacity of the optical fibers is doubling every 7 months while the processing CPU capacity (Moore's law) can only double every 18 months.
> 
> Moore's law is borne out in practice; most optical tansmission
> developments are theory.  3 years ago the fastest circuit you could
> readily buy from a carrier (QWest, 360, Williams, etc) was OC192.  Today I
> still can't contact a rep from any of those companies and order an OC768.

The above ignores the economics of the matter.
The money in optical carriers is currently in datacomm, not telecomm.
You'll see the highspeed optics in your server room before you see it
at your telco.
Companies that work with datacomm optical carriers are facing budget
limits with respect to software required for in house development of
hybrid ICs for highspeed datacom and compute resources for simulating
the highspeed analogue circuits required for optical datacom.
The theoretical switching speed is useless when the engineers are back to
designing digital circuits transistor by transistor and cannot verify
that all the circuits synchronize at those speeds.

-- 
Chris Dukes
I tried being reasonable once--I didn't like it.
