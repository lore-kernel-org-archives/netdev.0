From: bert hubert <ahu@ds9a.nl>
Subject: Re: IPv6 development plan ?
Date: Fri, 8 Nov 2002 10:22:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021108092205.GA16291@outpost.ds9a.nl>
References: <010101c28706$b1767840$21abfe81@seong>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Seong Moon <seong@etri.re.kr>
Content-Disposition: inline
In-Reply-To: <010101c28706$b1767840$21abfe81@seong>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 08, 2002 at 06:10:23PM +0900, Seong Moon wrote:

> The usagi says that the their product has applied the kernel.org partially.
> Why does not the original kernel apply the entire usagi patch ?

Things take time. The kernel people have been accepting USAGI patches at a
steady rate.

DaveM and Alexey have been reworking routing quite a lot, USAGI does not
apply cleanly to that. 

> And I want to know the master plan of development of IPv6 including IPv6
> routing functions. Could I know the schedule or plan ?

"When the time is right".

> He said that 2.6.x kernel series will contain a true and up-to-date IPv6
> implementation.
> Approximately When can I use 2.6.x kernel ?

I use it now, but you may not want to do that for mission critical systems.

Regards,

bert


-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
