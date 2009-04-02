From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] gianfar: Remove unused header
Date: Thu, 02 Apr 2009 01:14:12 -0700 (PDT)
Message-ID: <20090402.011412.193054111.davem@davemloft.net>
References: <1238506979-8678-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60287
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753485AbZDBIOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:14:23 -0400
In-Reply-To: <1238506979-8678-1-git-send-email-galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Tue, 31 Mar 2009 08:42:58 -0500

> Now that the driver is exclusively an of_platform driver we no longer
> use the structs and #defines in fsl_devices.h
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

Applied.
