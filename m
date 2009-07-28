From: Philip Craig <philipc@snapgear.com>
Subject: Re: [question] bridged tunnel
Date: Tue, 28 Jul 2009 18:12:28 +1000
Message-ID: <4A6EB2EC.3050907@snapgear.com>
References: <20090728075928.GB3633@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:60512 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751426AbZG1IM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:12:28 -0400
In-Reply-To: <20090728075928.GB3633@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Hello all.
> 
> Imagine following net scheme:
> 
> LAN1 --- ROUTER A --- ROUTER B --- LAN2
> 
> I would like to have LAN1 and LAN2 bridged together.

You can do that with gretap devices.

If you don't want to use GRE, then at least it provides an
example of how to do this in the kernel.
