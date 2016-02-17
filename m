From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] bnx2x: Add missing HSI for big-endian machines
Date: Wed, 17 Feb 2016 17:01:46 +0300
Message-ID: <56C47D4A.50302@cogentembedded.com>
References: <1455707714-5262-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariel.Elior@qlogic.com
To: Yuval Mintz <Yuval.Mintz@qlogic.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36235 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423150AbcBQOBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 09:01:50 -0500
Received: by mail-lb0-f171.google.com with SMTP id x1so9901280lbj.3
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 06:01:49 -0800 (PST)
In-Reply-To: <1455707714-5262-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/17/2016 2:15 PM, Yuval Mintz wrote:

> Commit e5d3a51cefbb "bnx2x: extend DCBx support" was missing HSI changes

    You forgot to also enclose the commit summary in parens.

> for big-endian machine, breaking compilation on such platforms.
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
[...]

MBR, Sergei
