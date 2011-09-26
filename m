From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [E1000-devel] intel 82599 multi-port performance
Date: Mon, 26 Sep 2011 11:46:57 -0600
Message-ID: <4E80BA91.2040803@genband.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com> <4E809D59.10103@gmail.com> <4E80A2AB.2040206@intel.com> <4E80AAF8.1000806@genband.com> <4E80B551.1040609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"J.Hwan.Kim" <j.hwan.kim99@gmail.com>, frog1120@gmail.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og124.obsmtp.com ([64.18.2.26]:55089 "EHLO
	exprod7og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab1IZRrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 13:47:20 -0400
In-Reply-To: <4E80B551.1040609@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2011 11:24 AM, Ben Greear wrote:
> On 09/26/2011 09:40 AM, Chris Friesen wrote:

>> To any of the Intel guys out there...any ideas? Can an 82599 on an 8x
>> bus handle max line rate with minimum size packets?
>
> Rick Jones sent me an interesting link related to this. Short answer seems
> to be 'yes', but it seems not for any normal off-the-shelf software stack.
>
>  > This: http://comments.gmane.org/gmane.linux.network/203602 should
> lead you to some slide.

Interesting.  I wonder if Intel's DPDK will be the only way to handle 
those sorts of packet rates.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
