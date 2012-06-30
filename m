From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [BUG, regression, bisected] Marvell 88E8055 NIC (sky2) fails to detect link after resume from S3
Date: Sat, 30 Jun 2012 22:02:36 +0200
Message-ID: <20120630200236.GA30058@electric-eye.fr.zoreil.com>
References: <op.wgon84tw16tawo@esprimo> <20120629164610.1f343434@nehalam.linuxnetplumber.net> <CAKKZj2DVX7Kr4Ag7jubtr7fSa5sSLYR=kt2b6=PV=8fV6q0d8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Michal Zatloukal <myxal.mxl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41242 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158Ab2F3UNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 16:13:41 -0400
Content-Disposition: inline
In-Reply-To: <CAKKZj2DVX7Kr4Ag7jubtr7fSa5sSLYR=kt2b6=PV=8fV6q0d8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Zatloukal <myxal.mxl@gmail.com> :
[...]
> Is there something I can try?

I have not used it for quite some time but comparing mmiotrace output
(see Documentation/trace/mmiotrace.txt) before and after the regression
commit may give some hint.

Otherwise I would ask for help on linux-pm@vger.kernel.org

-- 
Ueimor
