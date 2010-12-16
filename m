From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] via-velocity: fix the WOL bug on 1000M full duplex forced
 mode
Date: Thu, 16 Dec 2010 19:34:39 +0100
Message-ID: <4D0A5BBF.7000400@computer.org>
References: <AANLkTi=-MRrH1nCcbzqUMoP1sd=7opNGAz7KwmdoMmjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: David Lv <davidlv.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay002.isp.belgacom.be ([195.238.6.175]:51421 "EHLO
	mailrelay002.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757140Ab0LPSgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 13:36:18 -0500
In-Reply-To: <AANLkTi=-MRrH1nCcbzqUMoP1sd=7opNGAz7KwmdoMmjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/12/10 10:33, David Lv wrote:
> This patch isn't based on the first patch of the sleep speed 10M.
> The VIA velocity card can't be waken up by WOL tool on 1000M full
> duplex forced mode.
> This patch fixes the bug.
> Thanks!

This patch is whitespace-damaged. Your previous version (14 December) 
wasn't. Why did you resend? Is there a difference?

Thx, Jan
