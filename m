From: Ralph Doncaster <ralph@istop.com>
Subject: RE: TCP IP Offloading Interface
Date: Tue, 15 Jul 2003 15:01:11 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0307151451160.4590@ns.istop.com>
References: <E3738FB497C72449B0A81AEABE6E713C027A43@STXCHG1.simpletech.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jordi Ros <jros@xiran.com>
In-Reply-To: <E3738FB497C72449B0A81AEABE6E713C027A43@STXCHG1.simpletech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jul 2003, Jordi Ros wrote:

> Note that Microsoft is considering TOE under its Scalable Networking Program. To keep linux competitive, I would encourage a healthy discussion on this matter. Again, TOE is not the goal but the means to deliver important technologies for the next generation of servers. This will be critical as the backbone of the Internet goes to all optical networks while the servers stay at the electronic domain. As shown by McKeown, "Circuit Switching in the Core", the line capacity of the optical fibers is doubling every 7 months while the processing CPU capacity (Moore's law) can only double every 18 months.

Moore's law is borne out in practice; most optical tansmission
developments are theory.  3 years ago the fastest circuit you could
readily buy from a carrier (QWest, 360, Williams, etc) was OC192.  Today I
still can't contact a rep from any of those companies and order an OC768.

Even so, as things currently stand in Linux, an application can send a
stream of data from a file on disk to the network without any of the data
touching the CPU.  So we really don't need any new and convoluted way of
accelerating network performance.

> PROPRIETARY-CONFIDENTIAL INFORMATION INCLUDED

And you expect to be taken seriously when you include a stupid disclaimer
like this at the end of your email?

-Ralph
