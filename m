From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Subsystem/prefix in patch submission format
Date: Sun, 30 Jul 2006 14:01:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0607301342150.19037@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:24746 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP id S932261AbWG3LBN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 07:01:13 -0400
Received: from localhost (localhost [127.0.0.1])
	by kivilampi-30.cs.helsinki.fi (Postfix) with ESMTP id 9B391EAFE5
	for <netdev@vger.kernel.org>; Sun, 30 Jul 2006 14:01:11 +0300 (EEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have read through http://linux.yyz.us/patch-format.html, which uses 
$subsystem as prefix for summary. Could you please clarify what is 
appropriate "prefix" for the actual summary in a case where patch touches 
only a part of a subsystem, that is in my case, FRTO. Should the 
subsystem be TCP or can I use FRTO directly? Or should I perhaps use
them both (I found something similar from netdev archives and also from
some logs of the kernel):
   [TCP] FRTO: summary here

Just making sure, so that I can start to use the correct format of log 
messages in my git tree. Thank you.


-- 
 i.
