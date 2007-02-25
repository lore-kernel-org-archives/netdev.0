From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/7 RESEND] cxgb3 - Chelsio T3 1G/10G driver updates
Date: Sat, 24 Feb 2007 16:42:18 -0800
Message-ID: <45E0DB6A.2020909@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:17873 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932853AbXBYAmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 19:42:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'll be resending the series of incremental patches originally submitted 
on 02/22/07.

The series take in account Yoshifuji's comments.
Patch 2 - ioctl cleanup - is updated to secure backward compatibility.
The ioctls are now explicitly numbered.
Patch 6 is also updated with minor changes:
some comments are modified /* .. */  instead of // ..

The other patches remain unchanged.

Cheers,
Divy
