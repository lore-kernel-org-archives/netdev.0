From: "Gary N Spiess" <Gary.Spiess@Intermec.com>
Subject: Re: [PATCH] natsemi update 1/4 Use assigned MAC address
Date: Mon, 07 Jun 2004 16:12:49 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406071612490431.1B7F4FE7@136.179.85.112>
References: <200406041451590078.0BC23855@136.179.85.112>
 <40C31C71.6000101@colorfullife.com>
 <200406071258550931.1ACDCC8B@136.179.85.112>
 <20040607111638.663de0a6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: manfred@colorfullife.com, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040607111638.663de0a6@dell_ss3.pdx.osdl.net>
To: shemminger@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen,

Scrap patch 1 of 4, we don't need or want it.  (I'm feeling so sheepish.)

Thanks, Gary

*********** REPLY SEPARATOR  ***********

On 6/7/2004 at 11:16 AM Stephen Hemminger wrote:

>On Mon, 07 Jun 2004 12:58:55 -0500
>"Gary N Spiess" <Gary.Spiess@Intermec.com> wrote:
>
>> Jeff,
>> 
>> I agree with all comments.  Regarding the total elimination of this
>patch ...
>> 
>> Only our bootrom knows the MAC address that should be used, and it
>appends it to the bootargs.  If there is a way for the userspace to take a
>peek at the bootargs (or a similar mechanism), we can use the ifconfig
>method to assign the MAC address instead of changing the driver.  I'd
>prefer it.
>
>/proc/cmdline??


 oooooooooooooooooooooooooooooooooooooooooooooooooo
 Gary Spiess (Gary.Spiess@Intermec.com)
 MobileLan Wireless Products Group, Intermec Technology Corp
 voice: 319 369-3580  fax: 319 369-3804
