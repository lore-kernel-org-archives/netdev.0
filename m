From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Pushing the new FW to firmware git
Date: Mon, 23 May 2011 16:48:14 +0100
Message-ID: <1306165695.2627.10.camel@i7.infradead.org>
References: <201105231813.00751.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39852 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291Ab1EWPsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 11:48:17 -0400
In-Reply-To: <201105231813.00751.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-23 at 18:12 +0300, Vlad Zolotarov wrote:
> David, could u, pls., clarify about the exact procedure of pushing the new FW 
> to the  firwmware git: when exactly the new firware is going to be fetched to 
> the kernel tree? 
> 
> I'm asking it because I am going to submit a patch that introduces a new FW 
> and the new code will simply not work with an old FW. 

OK, so the new firmware gets a new filename, and you submit the new
firmware to the linux-firmware.git tree at the same time as you submit
the code changes to the kernel tree.

-- 
dwmw2

