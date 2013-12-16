From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH net-next 10/10] dccp: remove unused code
Date: Mon, 16 Dec 2013 15:27:23 -0700
Message-ID: <20131216152723.07d7a7aa@liptov.cs.ualberta.ca>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
	<20131216113943.4d9e9eae@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spey.erg.abdn.ac.uk ([139.133.204.173]:57646 "EHLO
	spey.erg.abdn.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab3LPW1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 17:27:32 -0500
In-Reply-To: <20131216113943.4d9e9eae@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(We had left it in there since the spec defines the option in RFC 4340, 13.2,
 but there had so far not been any need to use it.)

> This function is defined but not used.
> Remove it now, can come back when used.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
