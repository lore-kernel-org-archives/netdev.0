From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
	after receiving the Confirm option
Date: Fri, 25 Mar 2011 12:39:36 +0100
Message-ID: <20110325113936.GB3901@gerrit.erg.abdn.ac.uk>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk> <1299559831.7569.41.camel@jero-laptop> <20110311113042.GB4876@gerrit.erg.abdn.ac.uk> <1300048497.31664.158.camel@jero-laptop> <20110314115501.GB4631@gerrit.erg.abdn.ac.uk> <1300164791.20638.64.camel@jero-laptop> <20110318113052.GA5508@gerrit.erg.abdn.ac.uk> <4D88000F.80704@ohio.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Samuel Jero <sj323707@ohio.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:37168 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751588Ab1CYLjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 07:39:47 -0400
Content-Disposition: inline
In-Reply-To: <4D88000F.80704@ohio.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| Below is the very last patch you added to the test tree. I believe both
| of the changes made are not needed. See comments inline.
| > dccp ccid-2: replace remaining references to local Sequence Window value
| > 
Thank you for the explanation. I have removed this patch from the test tree
and resynchronized.
