From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-devel] Re: [bonding][2/3] Synchronizing 2.4-2.6
Date: Sat, 30 Aug 2003 22:39:40 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308302239.40237.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C94E5@hasmsx403.iil.intel.com> <3F4E27A2.9060204@pobox.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F4E27A2.9060204@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 28 August 2003 07:02 pm, Jeff Garzik wrote:
> Hen, Shmulik wrote:
> > After patch set 1, It should be as easy as just copying all the
> > bonding related files from 2.4 to 2.6. I guess I can do that on
> > Sunday if someone hasn't already done it before.
>
> I had hoped to preserve the revision history.  Simply copying the
> files over does not do that :(
>
> What I mean by preserving revision history is, changes should be
> submitted to 2.6 in the same granularity as they were to 2.4...
>

God, I wish I was an English speaking person...  :(
Amir, on the other hand, understood exactly what you intended, so 
there should be something ready for tomorrow that brings 2.6 to the 
same point as 2.4 after set 1, in small steps. After that, sets 2 and 
3 could be applied the same way for 2.4 and 2.6.


	Shmulik.
