From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/2] qlcnic: Implement flash sysfs callback for
 83xx adapter
Date: Tue, 12 Mar 2013 21:30:51 +0000
Message-ID: <1363123851.2780.31.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363114937-23283-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48265 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932707Ab3CLVaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 17:30:55 -0400
In-Reply-To: <1363114937-23283-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-12 at 15:02 -0400, Shahed Shaikh wrote:
> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> QLogic applications use these callbacks to perform
> 
> o  NIC Partitioning (NPAR) configuration and management
> o  Diagnostic tests
> o  Flash access and updates
> 
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
[...]

MTD is the standard Linux interface for raw flash devices.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
