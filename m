From: Ben Greear <greearb@candelatech.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Wed, 10 Jul 2002 15:56:40 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D2CBBA8.7080400@candelatech.com>
References: <20020710223237.GA7995@orr.falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se, garzik@mandrakesoft.com
Return-path: <owner-netdev@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> I've backported the most recent napi sources I could find to 2.4.19-rc1.
> The patches are available at http://orr.falooley.org/pub/linux/net/.
> 
> Testing and suggestions are welcome. Currently backported napi drivers
> are e1000, eepro100, tulip, and 3c59x. I intend to backport dl2k and
> sundance at some point, but I have no dl2k cards and I'm working with
> Donald Becker to get the sundance driver working on the card I have.
> 
> Does anyone know of more recent NAPI conversions? Robert Olsson tells me
> Jeff Garzik has a more recent tulip conversion, but there are _no_ napi
> net drivers in 2.5.25 and I haven't found any others except for those
> mentioned at the NAPI ftp site.
> 
> Jason

The tulip driver I saw on the napi web site was based off of the one
in kernel 2.4.2, which was back when tulip was broken for a lot of
cards (especially mine).

Is that where you got the basis for this last port?

Thanks, I'll try out the tulip and NAPI patches ASAP.

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
