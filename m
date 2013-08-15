From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: ethernet: ti: cpsw/mdio: suspend/resume
Date: Thu, 15 Aug 2013 15:27:51 +0530
Message-ID: <520CA61F.3050802@ti.com>
References: <520BECA2.90800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vaibhav Bedia <vaibhav.bedia@ti.com>, <netdev@vger.kernel.org>,
	Sebastian Siewior <bigeasy@linutronix.de>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:33231 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750986Ab3HOJ6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 05:58:01 -0400
In-Reply-To: <520BECA2.90800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 August 2013 02:16 AM, Daniel Mack wrote:
> Hi Mugunthan,
>
> Vaibhav told me that you are working on a patch to add suspend/resume
> functions to the cpsw and davinci_mdio driver, but searching my archives
> didn't bring up anything.
>
> May I ask whether you have a link to your work, or can I help here in
> any way?
>
>
> Thanks,
> Daniel
Sorry for re-posting the same mail as my previous mail was in html format

Thanks for your helping hand. All my patches for CPSW suspend/resume had
already applied and with Dave Gerlach AM335x suspend/resume patches CPSW
suspend/resume works fine. Dave Gerlach has his branch published at
below link which I had already tested suspend.resume with CPSW ping traffic.
https://github.com/dgerlach/linux-pm/tree/am335x-3.11rc4-suspend-resume

Regards
Mugunthan V N
