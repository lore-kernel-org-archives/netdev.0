From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: dccp: null-pointer dereference on close
Date: Tue, 1 Mar 2011 13:16:21 +0100
Message-ID: <20110301121621.GB3567@gerrit.erg.abdn.ac.uk>
References: <20110226174505.GB3609@localhost> <20110301055945.GA4761@gerrit.erg.abdn.ac.uk> <20110301120327.GA13273@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Johan Hovold <jhovold@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61926 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752450Ab1CAMQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 07:16:30 -0500
Content-Disposition: inline
In-Reply-To: <20110301120327.GA13273@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| Below are the bits that fixed the issue on 2.6.37. Perhaps this along
| with a more detailed description of the error, including the panic
| message, could serve as the basis for such a patch?
| 
Yes, thank you for the suggestion. I will incorporate your suggestions and submit the
reworked patch first thing tomorrow morning, need to go through the original also.
