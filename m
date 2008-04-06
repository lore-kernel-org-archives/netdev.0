From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111c weirdness problems, apic/msi, and normal bug
Date: Sun, 6 Apr 2008 16:06:24 +0200
Message-ID: <20080406140624.GA24479@electric-eye.fr.zoreil.com>
References: <1207407804.14885.27.camel@localhost> <20080405232354.57ff2fac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML Mailinglist <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: Kasper Sandberg <lkml@metanurb.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55654 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751598AbYDFOYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2008 10:24:36 -0400
Content-Disposition: inline
In-Reply-To: <20080405232354.57ff2fac.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> :
[...]
> > /proc/interrupts, dmesg, ethtool on .25 apic/nomsi?

Complete dmesg and lspci -vvxn for a start.

-- 
Ueimor
