From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] skge: fiber support
Date: Fri, 22 Sep 2006 20:16:45 -0400
Message-ID: <45147CED.10801@pobox.com>
References: <20060815131852.GP2900@mathom.us> <20060921153939.739947ab@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Stone <mstone@mathom.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33496 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932194AbWIWAQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 20:16:50 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060921153939.739947ab@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Add support for older fiber versions of the SysKonnect board. These chipsets
> use an internal PHY so they require special handling. The older sk98lin
> driver already supported these
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

ACK, but:


Applying 'skge: fiber support'

error: patch failed: drivers/net/skge.c:3107
error: drivers/net/skge.c: patch does not apply

