From: bert hubert <ahu@ds9a.nl>
Subject: Re: Patch: Backport of link state notification to 2.4.20rc1
Date: Thu, 14 Nov 2002 12:43:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021114114310.GA9977@outpost.ds9a.nl>
References: <3DD2D204.C9B7FA2D@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
Content-Disposition: inline
In-Reply-To: <3DD2D204.C9B7FA2D@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 13, 2002 at 11:28:20PM +0100, Stefan Rompf wrote:
> Hi,
> 
> having the link state notification stuff in 2.4 is still a major goal
> for me. I've taken the 2.5 implementation Jamal and I have worked out,
> removed the semantic changes towards RFC2863 and replaced the workqueue
> with a combination of timer and kevent.

By the way, is the 2.5 implementation going in? Would sure be lovely. 

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
