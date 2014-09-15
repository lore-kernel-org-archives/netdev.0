From: Mike Looijmans <mike.looijmans@topic.nl>
Subject: Re: [PATCH v2] net/phy: micrel: Disable asymmetric pause for KSZ9031
Date: Mon, 15 Sep 2014 09:44:53 +0200
Message-ID: <541698F5.2010401@topic.nl>
References: <5411ECE9.8050600@gmail.com>	<1410525637-849-1-git-send-email-mike.looijmans@topic.nl> <20140912.181820.1440041146938289489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vif1-retry101.mer-nm.internl.net ([217.149.192.107]:42611 "EHLO
	retry101.mer-nm.internl.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752380AbaIOHwi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 03:52:38 -0400
In-Reply-To: <20140912.181820.1440041146938289489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFOn 09/13/2014 12:18 AM, David Miller wrote:
> From: Mike Looijmans <mike.looijmans@topic.nl>
> Date: Fri, 12 Sep 2014 14:40:37 +0200
>
>> The KSZ9031 appears to suffer from the same hardware bug as describe=
d
>> for the KSZ9021 in commit 32fcafbcd1c9f6c7013016a22a5369b4acb93577
>> ("net/phy: micrel: Disable asymmetric pause for KSZ9021")
>> you have to unplug the cable and plug it back to get it to work.
>>
>> Remove the SUPPORTED_Asym_Pause flag for the KSZ9031 to fix this.
>>
>> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
>
> This patch does not apply cleanly to the net tree, please respin.
>

Okay, just tell me where to find this branch?

Mike.


Met vriendelijke groet / kind regards,

Mike Looijmans

TOPIC Embedded Systems
Eindhovenseweg 32-C, NL-5683 KH Best
Postbus 440, NL-5680 AK Best
Telefoon: (+31) (0) 499 33 69 79
Telefax:  (+31) (0) 499 33 69 70
E-mail: mike.looijmans@topic.nl
Website: www.topic.nl

Please consider the environment before printing this e-mail

Topic zoekt gedreven (embedded) software specialisten!
http://topic.nl/vacatures/topic-zoekt-software-engineers/
