From: Joe Perches <joe@perches.com>
Subject: Re: [XFRM]: constify 'struct xfrm_type'
Date: Thu, 24 Jan 2008 11:37:44 -0800
Message-ID: <1201203464.16268.50.camel@localhost>
References: <20080124122621.3248c651.dada1@cosmosbay.com>
	 <1201195057.16268.32.camel@localhost>  <4798D7B9.5090406@cosmosbay.com>
	 <1201199858.16268.46.camel@localhost>  <4798E5E1.9050408@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2148 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1757655AbYAXTim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 14:38:42 -0500
In-Reply-To: <4798E5E1.9050408@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-01-24 at 20:24 +0100, Eric Dumazet wrote:
> I still dont understand what *you* want to do.

Mark the accesses as "* const" not "const *"


