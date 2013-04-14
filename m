From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 4/9] qlcnic: fix beaconing test for 82xx adapter
Date: Sun, 14 Apr 2013 12:55:33 +0200
Message-ID: <20130414105533.GC30385@electric-eye.fr.zoreil.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
 <1365874114-6759-5-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44074 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab3DNKzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 06:55:39 -0400
Content-Disposition: inline
In-Reply-To: <1365874114-6759-5-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shahed Shaikh <shahed.shaikh@qlogic.com> :
> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> o Commit 319ecf121e1da3d75dd1bde32fed255532e61797
>   ("qlcnic: 83xx sysfs routines") introduced regression
>   for beaconing test while refactoring 82xx code. This patch is to
>   revert code to fix beaconing test for 82xx adapter.

Fix ought to go through net, not net-next.

-- 
Ueimor
