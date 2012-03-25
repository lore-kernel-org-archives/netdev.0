From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [PATCH v8 RESEND] ARM: net: JIT compiler for packet filters
Date: Sun, 25 Mar 2012 15:12:34 +0200
Message-ID: <4F6F19C2.60602@gmail.com>
References: <1331933316-10197-1-git-send-email-mgherzan@gmail.com> <20120319.172005.1889334604020296555.davem@davemloft.net> <4F6EEAB5.7070009@gmail.com> <20120325095711.GC5611@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:62223 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065Ab2CYNMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 09:12:39 -0400
Received: by wibhj6 with SMTP id hj6so3452673wib.1
        for <netdev@vger.kernel.org>; Sun, 25 Mar 2012 06:12:38 -0700 (PDT)
In-Reply-To: <20120325095711.GC5611@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 25.03.2012 11:57, schrieb Russell King - ARM Linux:
> On Sun, Mar 25, 2012 at 11:51:49AM +0200, Mircea Gherzan wrote:
>> Am 19.03.2012 22:20, schrieb David Miller:
>>> I would like to see this merged however is feasible, this has been in
>>> a catatonic state for two releases and waiting longer isn't going to
>>> improve things enough to justify any further delay.
>>
>> It has been merged into the ARM tree more than a week ago, but
>> unfortunately it seems it will not make it into 3.4.
> 
> Why do you say that?

The patch is nowhere to be found in any of the branches of your
linaro.org tree, the tree from which Linus pulls.
