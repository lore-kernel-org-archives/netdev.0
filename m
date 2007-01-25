From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought
 up
Date: Thu, 25 Jan 2007 13:50:33 +0100
Message-ID: <20070125135033.7d7d7baf@griffin.suse.cz>
References: <1169707854.10593.41.camel@dv>
	<a32f33a40701250347q5c9aa5fby785181f77fc9bb4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Pavel Roskin" <proski@gnu.org>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
To: "Ivo Van Doorn" <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:38267 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965280AbXAYMum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 07:50:42 -0500
In-Reply-To: <a32f33a40701250347q5c9aa5fby785181f77fc9bb4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Jan 2007 12:47:08 +0100, Ivo Van Doorn wrote:
> Correct, similar problems have been detected in rt2x00. The temporary
> solution in there is to demand a scanning operation after the interface
> has been brought up.

Scanning? No no no, please! That would be a clear bug and misbehaviour.

 Jiri

-- 
Jiri Benc
SUSE Labs
