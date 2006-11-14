From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] NetXen: Fixed /sys mapping between device and driver
Date: Tue, 14 Nov 2006 10:26:58 -0500
Message-ID: <4559E042.6080100@garzik.org>
References: <Pine.LNX.4.64.0611070818320.26206@dut39> <Pine.LNX.4.64.0611070835060.26206@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, wendyx@us.ibm.com,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:960 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965938AbWKNP1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:27:05 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <Pine.LNX.4.64.0611070835060.26206@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale wrote:
> 
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>

ACK technical content, but git-applymbox claims the patches are corrupted.

Also, please realize that your email subject line is used as a one-line 
summary for your change, copied directly into the kernel change log. 
ref http://linux.yyz.us/patch-format.html

As such, having two patches with the identical subject "NetXen: 1G/10G 
Ethernet Driver updates" is bad form, because it is overly vague, and 
fails to adequately summarize the changeset.

Example summaries:
patch #2: NetXen: temp monitoring, de-bloat, support newer firmware
patch #3: NetXen: driver cleanup, 64-bit memory fixes

