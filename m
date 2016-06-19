From: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Sun, 19 Jun 2016 23:45:47 +0900
Message-ID: <5766B01B.9070903@sakamocchi.jp>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain> <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk> <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
 <20160618224549.GF32724@icarus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@linaro.org>, linux-media@vger.kernel.org
To: Henrik Austad <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-proxy001.phy.lolipop.jp ([157.7.104.42]:36367 "EHLO
	smtp-proxy001.phy.lolipop.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751513AbcFSOpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 10:45:53 -0400
In-Reply-To: <20160618224549.GF32724@icarus.home.austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(remove C.C. to lkml. This is not so major feature.)

On Jun 19 2916 07:45, Henrik Austad wrote:
> snip
>
> 802.1Q gives you low latency through the network, but more importantly, no
> dropped frames. gPTP gives you a central reference to time.

When such a long message is required, it means that we don't have enough 
premises for this discussion.

You have just interests in gPTP and transferring AVTPDUs, while no 
interests in the others such as "what the basic ideas of TSN come from" 
and "the reason that IEEE 1722 refers to IEC 61883 series which is 
originally designed for IEEE 1394 bus" and "the reason that I was 
motivated to join in this discussion even though not a netdev developer".

Here, could I ask you a question? Do you know a role of cycle start 
packet of IEEE Std 1394?

If you think it's not related to this discussion, please tell it to me. 
Then I'll drop out from this thread.


History Repeats itself.

Takashi Sakamoto
