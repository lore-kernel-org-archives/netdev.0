From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: tbench regression on each kernel release from  2.6.22 -> 2.6.28
Date: Mon, 11 Aug 2008 13:56:21 -0500
Message-ID: <48A08B55.4030004@linux-foundation.org>
References: <48A086B6.2000901@linux-foundation.org> <48A08A11.8040507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52170 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753141AbYHKS4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 14:56:48 -0400
In-Reply-To: <48A08A11.8040507@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:

> is this with SLAB or with SLUB? SLUB has been known to impact network performance...

The original testing config was SLAB based so it was used throughout.

