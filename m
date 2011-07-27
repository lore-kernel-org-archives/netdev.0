From: Rick Jones <rick.jones2@hp.com>
Subject: Re: IP over 802.2 with LLC/SNAP
Date: Wed, 27 Jul 2011 09:26:36 -0700
Message-ID: <4E303C3C.5040802@hp.com>
References: <4E2F8B7B.80906@signal11.us> <20110727133209.0d9dd6c4@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan@signal11.us>, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:36211 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754603Ab1G0Q0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 12:26:39 -0400
In-Reply-To: <20110727133209.0d9dd6c4@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2011 05:32 AM, Alan Cox wrote:
>> So the question is, does Linux support IP over 802.2 with LLC/SNAP? Is
>> there a sysfs/proc entry that I have to turn on to make this work (I
>> didn't find one)? I have the LLC2 module loaded, and I believe my packet
>> to be correct, since Windows recognizes it and since Wireshark doesn't
>> give any red flags on it. I've been unable to find anything about this
>> kind of thing in my searching.
>
> Linux supports LLC/SNAP and various things over it (IPX/Appletalk DDP
> etc) but not IP over it, as it's one of those standards bodies driven
> bogosities which nobody ever actually deployed.

Well...  Hewlett-Packard deployed it in the 80's and 90's in MPE and 
HP-UX, HP-UX because until the mid-ish 1990's MPE only spoke 802.2 not 
"Ethernet."  By the late 1990's I think it was gone from HP-UX.

rick jones
