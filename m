From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v3 3/3] ptp: Added a clock that uses the eTSEC found on
 the MPC85xx.
Date: Mon, 17 May 2010 17:41:44 +0200
Message-ID: <4BF163B8.9070509@grandegger.com>
References: <cover.1273855016.git.richard.cochran@omicron.at> <ee6c3edca3ee6aa86565e59da999375f79c9de1b.1273855017.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:32832 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab0EQPmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 11:42:09 -0400
In-Reply-To: <ee6c3edca3ee6aa86565e59da999375f79c9de1b.1273855017.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/14/2010 06:46 PM, Richard Cochran wrote:
> The eTSEC includes a PTP clock with quite a few features. This patch adds
> support for the basic clock adjustment functions, plus two external time
> stamps and one alarm.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Tested-by: Wolfgang Grandegger <wg@denx.de>

on my Freescale MPC8313 setup with ptpd and ptpv2d.

FYI: checkplatch.pl reports various errors for this patch series.

Wolfgang.
