From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH] bnx2x: Update to FW 7.8.19
Date: Thu, 6 Feb 2014 15:26:11 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF44845@SJEXCHMB10.corp.ad.broadcom.com>
References: <1390921061-22019-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: "dwmw2@infradead.org" <dwmw2@infradead.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:10314 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaBFP0N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 10:26:13 -0500
In-Reply-To: <1390921061-22019-1-git-send-email-yuvalmin@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This new firmware fixes several bugs:
>  1. HW attention appears and traffic stops when iSCSI firmware tries to
>     retransmit iSCSI login command when the iSCSI login is carrying data
>     not aligned to 4-bytes.
>  2. FCoE traffic fails to run when running in switch-independent multi-function
>     mode and there's more than one interface supporting FCoE on a given port.
>  3. While two ports are running FCoE with at least one of them has a function
>     number (>1) on the same engine in a 4-port device a zeroed CQE is given,
>     causing FCoE traffic to stop.

Hi, any news about this one?

Thanks,
Yuval
