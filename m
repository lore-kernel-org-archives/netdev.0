From: jamal <hadi@cyberus.ca>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 06 Aug 2008 09:17:14 -0400
Message-ID: <1218028634.4755.69.camel@localhost>
References: <200808060042.53503.denys@visp.net.lb>
	 <200808061550.42003.denys@visp.net.lb> <1218027312.4755.63.camel@localhost>
	 <200808061559.07923.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:60717 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbYHFNRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 09:17:17 -0400
Received: by yx-out-2324.google.com with SMTP id 8so284986yxm.1
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 06:17:17 -0700 (PDT)
In-Reply-To: <200808061559.07923.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-08 at 15:59 +0300, Denys Fedoryshchenko wrote:

> 
> This one?

Sure thing Denys. Again - appreciated. 
Do you know how to use git?
When you send such patches so that Stephen can apply them, it is nicer
if you have proper comments and signed offs. If you havent learnt how to
use it, could be a fun thing to try out.

I have tested the version of the patch i suggested earlier. I could not
reproduce the crash but it is very clear from printfs it was a bug.
If you dont mind please test it as well on your side and then send the
patch to Stephen with my ACK.

cheers,
jamal

