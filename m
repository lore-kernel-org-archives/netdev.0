From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: [Odd commit author id merge via netdev]
Date: Fri, 1 Apr 2016 10:51:10 -0700
Message-ID: <56FEB50E.4060004@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22700 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbcDARvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 13:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I noticed something odd while checking the recent
commits of mine in kernel.org tree made it via netdev.

Don't know if its patchwork tool doing this.
Usual author line in my git objects	:
	Author: Santosh Shilimkar <emaid-id>

But the commits going via your tree seems to be like below..
	Author: email-id <email-id>

Few more examples of the commits end of the email. Can this
be fixed for future commits ? The git objects you pulled from
my tree directly have right author format where as ones which
are picked from patchworks seems to be odd.

Regards,
Santosh

commit ad6832f950d35df8c70b577993a24b31b34d88e4
Author: santosh.shilimkar@oracle.com <santosh.shilimkar@oracle.com>

commit 2cb2912d65633e751d3f8397377174501412aa47
Author: santosh.shilimkar@oracle.com <santosh.shilimkar@oracle.com>

commit db42753adb638b63572583162bb08ea193947309
Author: santosh.shilimkar@oracle.com <santosh.shilimkar@oracle.com>


[....]

commit 06766513232d1619ac84e87b1d839d3fcc23a540
Author: Santosh Shilimkar <santosh.shilimkar@oracle.com>

commit 41a4e9646229801624e38f7a1cc53033a0affdb1
Author: Santosh Shilimkar <santosh.shilimkar@oracle.com>
