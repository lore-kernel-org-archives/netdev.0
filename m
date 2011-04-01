From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH 0/9 net-next-2.6] qlcnic: Code cleanup and fixes
Date: Fri, 1 Apr 2011 15:03:49 -0700
Message-ID: <E6A59B41-286C-4C7D-881D-652963BAFA9D@qlogic.com>
References: <alpine.OSX.2.00.1103312119400.47460@n5102mn2hhgf91.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:23691 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757317Ab1DAWEx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 18:04:53 -0400
In-Reply-To: <alpine.OSX.2.00.1103312119400.47460@n5102mn2hhgf91.qlogic.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 31, 2011, at 9:31 PM, Anirban Chakraborty wrote:

> Please apply.
>
> thanks,
> Anirban
>

It turned out that patch no. 8 has a conflict with the following patch:

commit 673e63c688f43104c73aad8ea4237f7ad41fa14d
net: fix ethtool->set_flags not intended -EINVAL return value

Please do not apply the current series as I'm resending it.

thanks,
Anirban



This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

