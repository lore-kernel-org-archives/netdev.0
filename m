From: speedy <speedy@3d-io.com>
Subject: Re[2]: [BUG REPORT] 2.6.21-rc7 - Yukon-EC Ultra <-> sky2 driver bug(s)
Date: Fri, 27 Apr 2007 01:19:56 +0200
Message-ID: <183140279.20070427011956@3d-io.com>
References: <1005889901.20070426035905@3d-io.com> <20070426130339.109e42ea@freekitty> <1901675644.20070427003443@3d-io.com> <20070426153517.2a78c3c4@dxpl.pdx.osdl.net>
Reply-To: speedy <speedy@3d-io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bromine.webpack.hosteurope.de ([217.115.142.123]:45040 "EHLO
	bromine.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031506AbXDZXUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 19:20:03 -0400
In-Reply-To: <20070426153517.2a78c3c4@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stephen,

Friday, April 27, 2007, 12:35:17 AM, you wrote:

SH> On Fri, 27 Apr 2007 00:34:43 +0200
SH> speedy <speedy@3d-io.com> wrote:

>> Hello Stephen,
>> 
>> Thursday, April 26, 2007, 10:03:39 PM, you wrote:
>> 
>> SH> On Thu, 26 Apr 2007 03:59:05 +0200
>> SH> speedy <speedy@3d-io.com> wrote:
>> 
>> >> Kernel: 2.6.21-rc7
>> >> Device: Yukon-EC Ultra (0xb4) rev 2 [integrated on Gigabyte GA-965P-DQ6]
>> >> OS: Ubuntu 7.04 (Feisty Fawn)

SH> I have that motherboard, that is why I blacklisted it..
SH> Neither my driver (or the vendor driver works). Right now I suspect some
SH> problem unique to full x86-64 mode. Windows runs it in i386 mode.

The box is running in 32bit mode, for both Linux and Windows if that matters.
Umm - at least I think so for Linux.. I think Ubuntu is a 32bit
version. Hmm.. "uname -a" says i686.

Maybe there are tools to sniff the bus traffic of the Windows driver and
compare it to what you do? (ie. like what folk from NVidia open-source drivers
are doing..) I suspect you are touching something windows driver does not -
so it requires power-off/power-on to resume normal device operation.

Cheers,
speedy over&out

