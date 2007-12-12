From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 1/2] qe: add function qe_clock_source()
Date: Wed, 12 Dec 2007 09:19:07 -0600
Message-ID: <475FFBEB.60005@freescale.com>
References: <11967166791607-git-send-email-timur@freescale.com> <1196716680381-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:34020 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbXLLPTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 10:19:16 -0500
In-Reply-To: <1196716680381-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi wrote:
> Add function qe_clock_source() which takes a string containing the name of a
> QE clock source (as is typically found in device trees) and returns the
> matching enum qe_clock value.
> 
> Update booting-without-of.txt to indicate that the UCC properties rx-clock
> and tx-clock are deprecated and replaced with rx-clock-name and tx-clock-name,
> which use strings instead of numbers to indicate QE clock sources.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

If there are no objections, I'd like this patch to be pulled into 2.6.25.  Thanks.

-- 
Timur Tabi
Linux kernel developer at Freescale
