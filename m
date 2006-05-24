From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [PATCH 1/4] b44: add wol and setup for later 4401
Date: Wed, 24 May 2006 08:27:57 -0700
Message-ID: <1148484477.2976.63.camel@dhcp-10-7-81-7.broadcom.com>
References: <1148481644.2976.51.camel@dhcp-10-7-81-7.broadcom.com>
 <20060524220658.GA2863@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:6160 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S964782AbWEXW3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 18:29:41 -0400
To: "Francois Romieu" <romieu@fr.zoreil.com>
In-Reply-To: <20060524220658.GA2863@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-05-25 at 00:06 +0200, Francois Romieu wrote:

> Should b44_setup_wol() not be used in b44_suspend() as well ?
> 

Yes. Thank you.

> (nit: s/){/) {/)
> 

ok.

