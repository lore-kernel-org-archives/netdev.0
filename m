From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix mace_handle_misc_intrs compilation
Date: Mon, 24 Sep 2007 01:22:46 -0700
Message-ID: <20070924012246.6ae8858f.akpm@linux-foundation.org>
References: <20070924081501.GA1797@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54684 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752032AbXIXIXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 04:23:37 -0400
In-Reply-To: <20070924081501.GA1797@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Sep 2007 10:15:01 +0200 Olaf Hering <olaf@aepfle.de> wrote:

> Fix compilation after incomplete struct net_device changes.

yup, thanks, Kamalesh Babulal has already sent in an identical
patch.
