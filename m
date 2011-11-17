From: John Crispin <blogic@openwrt.org>
Subject: Re: [PATCH 1/3] NET: MIPS: lantiq: make etop ethernet work on ase/ar9
Date: Thu, 17 Nov 2011 12:00:58 +0100
Message-ID: <4EC4E96A.203@openwrt.org>
References: <1321454508-4754-1-git-send-email-blogic@openwrt.org> <20111116.220220.2004448468476437215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:44413 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756383Ab1KQKB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 05:01:27 -0500
In-Reply-To: <20111116.220220.2004448468476437215.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/11/11 04:02, David Miller wrote:
> From: John Crispin <blogic@openwrt.org>
> Date: Wed, 16 Nov 2011 15:41:46 +0100
>
>> Extend the driver to handle the different DMA channel layout for AR9 and
>> Amazon-SE SoCs. The patch also adds support for the integrated PHY found
>> on Amazon-SE and the gigabit switch found inside the AR9.
>>
>> Signed-off-by: John Crispin <blogic@openwrt.org>
>> Cc: netdev@vger.kernel.org
> Since these patches (at least partially) modify MIPS files, please submit
> them via the MIPS maintainer.
>
> Feel free to add:
>
> Acked-by: David S. Miller <davem@davemloft.net>
>

Thank you !
