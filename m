From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [dccp] [RFC/RFT] [Patch 1/2]: Allow to distinguish original and
	retransmitted packets
Date: Thu, 5 Jun 2008 15:45:29 +0100
Message-ID: <20080605144529.GB8800@gerrit.erg.abdn.ac.uk>
References: <4846462F.3020004@cn.fujitsu.com> <20080604132152.GA17595@ghostprotocols.net> <20080604133849.GA5583@gerrit.erg.abdn.ac.uk> <20080604154452.GB4625@ghostprotocols.net> <20080604155540.GA16194@gerrit.erg.abdn.ac.uk> <20080605144435.GA8800@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Wei Yongjun <yjwei@cn.fujitsu.com>,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61147 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753869AbYFEOpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 10:45:55 -0400
Content-Disposition: inline
In-Reply-To: <20080605144435.GA8800@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dccp: Allow to distinguish original and retransmitted packets
