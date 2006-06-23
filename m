From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.17] AT91RM9200 Ethernet #1: Link poll
Date: Thu, 22 Jun 2006 22:56:37 -0400
Message-ID: <449B5865.5020800@pobox.com>
References: <1150797022.15581.329.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:4998 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750985AbWFWC4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 22:56:44 -0400
To: Andrew Victor <andrew@sanpeople.com>
In-Reply-To: <1150797022.15581.329.camel@fuzzie.sanpeople.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Victor wrote:
> For Ethernet PHYs that don't have an IRQ pin or boards that don't
> connect the IRQ pin to the processor, we enable a timer to poll the
> PHY's link state.
> 
> Patch originally supplied by Eric Benard and Roman Kolesnikov.

applied patches 1-4


