From: Ryan Raasch <ryan.raasch@gmail.com>
Subject: Disable pxa dma option for smc911x
Date: Mon, 14 Dec 2009 14:22:51 +0100
Message-ID: <4B263C2B.8080609@gmail.com>
References: <4B263A4F.8050302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:32869 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756113AbZLNNW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 08:22:56 -0500
Received: by qw-out-2122.google.com with SMTP id 3so659391qwe.37
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2009 05:22:56 -0800 (PST)
In-Reply-To: <4B263A4F.8050302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Because our system, we have had to disable the dma for our chip :) We
don't know why yet...

However, when disabling the DMA, there are a couple of cpp errors, which
this patch fixes.

Greetings,
Ryan

