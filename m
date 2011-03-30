From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Use VPI.VCI notation uniformly.
Date: Wed, 30 Mar 2011 16:03:58 -0700 (PDT)
Message-ID: <20110330.160358.55865087.davem@davemloft.net>
References: <1301525787-28447-1-git-send-email-philipp_subx@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: philipp_subx@redfish-solutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37811
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754521Ab1C3XEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 19:04:36 -0400
In-Reply-To: <1301525787-28447-1-git-send-email-philipp_subx@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Date: Wed, 30 Mar 2011 16:56:27 -0600

> From: Philip A. Prindeville <philipp@redfish-solutions.com>
> 
> Use VPI.VCI notation consistently throughout the module. This is the
> one remaining place where the VCI is used before the VPI in any output.
> 
> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
> ---
>  drivers/atm/solos-pci.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

Why do your subject lines not have an appropriate prefix?

How will someone scanning the commit header lines in the tree know
that this is a change to the solos-pci driver unless you prefix
them with "solos-pci: " or similar?
