From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 09:39:03 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D2D8A77.8060401@mandrakesoft.com>
References: <20020710223237.GA7995@orr.falooley.org> <Pine.GSO.4.30.0207101917480.22734-100000@shell.cyberus.ca> <20020711132604.GC12354@orr.falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
   greearb@candelatech.com, garzik@mandrakesoft.com
Return-path: <owner-netdev@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> On Wed, Jul 10, 2002 at  7:34PM -0400, jamal wrote:
>>tested with Znyx 4 port ethernet cards; For the best perfomance (at
>>least on the Znyx Nics) turn on MMIO (selected from kernel config).
> 
> 
> Do you know if this would also apply to the DLink 4-port tulip cards
> (DFE-570TX)? They're based on intel 21143's.

Yes, MMIO will speed up pretty much any tulip card

	Jeff
