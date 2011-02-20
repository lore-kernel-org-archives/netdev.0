From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: Advice on network driver design
Date: Sun, 20 Feb 2011 19:14:54 +0100
Message-ID: <4D615A1E.5070002@neli.hopto.org>
References: <4D5FC7A7.5050704@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Felix Radensky <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-02.edutel.nl ([88.159.1.176]:58694 "EHLO
	edu-smtp-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204Ab1BTSVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 13:21:39 -0500
In-Reply-To: <4D5FC7A7.5050704@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix Radensky wrote:
> The host platform is Freescale P2020. The custom hardware is
> FPGA with several TX FIFOs, single RX FIFO and a set of registers.

Wasn't it easier to use the in-SOC ethernet controllers?

Micha
