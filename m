From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] add init_dummy_netdev() for napi only dummy intefaces
Date: Thu, 14 Dec 2006 07:42:32 +1100
Message-ID: <1166042552.11914.188.camel@localhost.localdomain>
References: <1165901258.11914.32.camel@localhost.localdomain>
	 <20061213113537.6baf410f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50514 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770AbWLMUmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 15:42:43 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061213113537.6baf410f@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-13 at 11:35 -0800, Stephen Hemminger wrote:

> Could we split off the NAPI context part of network_device instead?
> I'll work up something for 2.6.21.

That would do the trick too... though I prefer not putting my hands in
network_device too much myself :-)

Ben

