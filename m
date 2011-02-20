From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: Advice on network driver design
Date: Sun, 20 Feb 2011 23:01:32 +0200
Message-ID: <4D61812C.2000003@embedded-sol.com>
References: <4D5FC7A7.5050704@embedded-sol.com> <4D615A1E.5070002@neli.hopto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Micha Nelissen <micha@neli.hopto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh78.surpasshosting.com ([72.29.64.142]:42540 "EHLO
	sh78.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548Ab1BTVBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:01:23 -0500
In-Reply-To: <4D615A1E.5070002@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Micha

On 02/20/2011 08:14 PM, Micha Nelissen wrote:
> Felix Radensky wrote:
>> The host platform is Freescale P2020. The custom hardware is
>> FPGA with several TX FIFOs, single RX FIFO and a set of registers.
>
> Wasn't it easier to use the in-SOC ethernet controllers?

FPGA talks some satellite protocol to the outside world, so the
target box is essentially a ethernet to satellite router.

Felix.
