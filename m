From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: 2.6.10 ipv6/8021q lockup on vconfig on interface removal
Date: Tue, 18 Jan 2005 10:14:11 +0200
Message-ID: <200501181014.12079.hasso@estpak.ee>
References: <41EA0A01.2020707@tomt.net> <41EC0F2B.7010002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andre Tomt <andre@tomt.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41EC0F2B.7010002@candelatech.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Andre Tomt wrote:
> > I sent this initially about a week ago, but nobody have said anything,
> > not even a confirmation that its beeing looked into, or about me beeing
> > silly - highly unusual on netdev! So I'm reposting (with slight
> > modifications), boo, shame on me. Just a bit worried it slipped through
> > the cracks.
>
> My take on this is that it is a bug in the IPv6 code.  If the IPv6 people
> think that the VLAN code might could be causing this, then I am open to
> suggestions as to how the VLAN code might be in error....

There were similar problems with tunnels in 2.6.8 and 2.6.9 kernels. They 
seems to be gone now in 2.6.10.

Does it help, Andre?


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
