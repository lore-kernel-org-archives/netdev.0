From: Koon Wah Yick <kyick@alcatel-lucent.com>
Subject: Enable netem in my Linux box
Date: Wed, 09 May 2007 11:31:17 -0400
Message-ID: <4641E945.3070902@lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Yick, Koon Wah (Koon)" <kyick@homail.ho.lucent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hoemail2.lucent.com ([192.11.226.163]:39911 "EHLO
	hoemail2.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbXEIPgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 11:36:42 -0400
Received: from homail.ho.lucent.com (h135-17-192-10.lucent.com [135.17.192.10])
	by hoemail2.lucent.com (8.13.8/IER-o) with ESMTP id l49FVHme022191
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 10:31:18 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

My Linux box has CentOS5 installed.  But I could not run tc command with any
netem parameters in command line. as shown in web site
http://linux-net.osdl.org/index.php/Netem.  I suspect, Netem was either not part
of the installed OS or has not been enabled.  Can you tell how to verified?
When I type in "rpm -qa" I see only iproute-2.6.18-4.el5, do I need iproute2?
Can you tell me how to update my Linux kernel to include netem functionality.
Thanks,

Koon-Wah.


