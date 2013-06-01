From: Philip Rakity <prakity@nvidia.com>
Subject: TCP.h  #undef STATE_TRACE  question
Date: Sat, 1 Jun 2013 12:14:02 +0200
Message-ID: <F67CC1DB-8F2B-4186-A1C4-E42BA1D20602@nvidia.com>
References: <50A540EE-1922-4648-8898-452DB90515DD@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate14.nvidia.com ([216.228.121.143]:7927 "EHLO
	hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab3FAKN7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 06:13:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> In include/net/tcp.h there is a 
> #undef STATE_TRACE
> 
> just before the
> #define STATE_TRACE
> 
> This breaks printing out the state info in tcp.c.
> 
> It is from a checkin from Linus when he moved the code base over to git in 2005.  
> I did not try to go back before that.
> 
> Any reason why it is there ?  I can submit a patch to remove it.
> 
> regards,
> 
> Philip
> 

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
