From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 02/10] tcp: move tcp_simple_retransmit to tcp_input
Date: Mon, 24 Nov 2008 17:36:20 +0100
Message-ID: <87skphqdx7.fsf@basil.nowhere.org>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39813 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004AbYKXQgR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 11:36:17 -0500
In-Reply-To: <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 (Ilpo =?utf-8?Q?J=C3=A4rvinen's?= message of "Mon, 24 Nov 2008 16:21:59
 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> writes:

tcp: move tcp_simple_retransmit to tcp_input

Why? It seems like a clear output function.

-Andi

--=20
ak@linux.intel.com
