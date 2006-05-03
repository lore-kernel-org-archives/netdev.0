From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: VJ Channel API - driver level (PATCH)
Date: Wed, 3 May 2006 10:52:19 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F149E8AC@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:38415 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750910AbWECRwh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 13:52:37 -0400
Content-class: urn:content-classes:message
To: "Alex Aizman" <alex@neterion.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Are you proposing a mechanism for the consuming end of a tx
channel to support a large number of channels, or are you
assuming that the number of tx channels will be small enough
that simply polling them in priority order is adequate?

