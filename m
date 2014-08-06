From: Stefano Babic <sbabic@denx.de>
Subject: Re: [Regression] FEC: Panic on suspend in 3.16
Date: Wed, 06 Aug 2014 17:52:58 +0200
Message-ID: <53E24F5A.2000309@denx.de>
References: <53E24147.4050304@parkeon.com> <53E24525.2020809@mentor.com> <53E24A99.2020604@denx.de> <20140806154711.GQ30282@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Nathan Lynch <Nathan_Lynch@mentor.com>,
	Martin Fuzzey <mfuzzey@parkeon.com>, netdev@vger.kernel.org,
	festevam@gmail.com,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Stefano Babic <sbabic@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:56214 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbaHFPxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 11:53:01 -0400
In-Reply-To: <20140806154711.GQ30282@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russel,

On 06/08/2014 17:47, Russell King - ARM Linux wrote:

> As Nathan says, the problem is caused by a71e3c37960c and the fix which
> will soon be merged into mainline and stable trees will be a revert of
> that commit.

I see. Thanks for explanation.

Stefano


-- 
=====================================================================
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-53 Fax: +49-8142-66989-80 Email: sbabic@denx.de
=====================================================================
