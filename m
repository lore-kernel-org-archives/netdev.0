From: Craig Thomas <craiger@osdl.org>
Subject: Re: Fw: Network driver test suite?
Date: Tue, 11 Jan 2005 17:32:34 -0800
Message-ID: <1105493554.28674.49.camel@bullpen.pdx.osdl.net>
References: <20050105152635.290ad9c0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dhollis@davehollis.com, cliffw@osdl.org, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050105152635.290ad9c0@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-05 at 15:26, Stephen Hemminger wrote:
> Begin forwarded message:
> 
> Date: Wed, 05 Jan 2005 15:19:46 -0500
> From: David Hollis <dhollis@davehollis.com>
> To: Netdev <netdev@oss.sgi.com>
> Subject: Network driver test suite?
> 
> 
> Is there any kind of test suite (automated or list of tests) available
> for testing Linux network drivers?  I'm completing the addition of a few
> new USB ethernet devices and would like to able to test all possible
> scenarios instead of coming across them piece-meal in the future.  I'm
> not a big fan of the "works on my box" testing that I'm doing now.  I'm
> sure there are all kinds of things that I'm not testing that aren't
> everyday types of things such as VLANs, multicasting, various
> ethtool/mii-tool things, large packets, etc.

Would there be a desire for someone to collect the tests or at least
create an index to all their locations?  If so, then developers can
scan a library of potential tests to run against newly developed code.

OSDL can start incorporating some of these tests into their test
platform as well.


> 
> If there isn't anything like this, maybe it would be a useful thing to
> develop?  At a minimum, maybe to set the treshhold for minimum features
> that drivers support and the like.
