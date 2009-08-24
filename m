From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 1/3] Set socket flags on restore using sock_setsockopt() where possible (v2)
Date: Mon, 24 Aug 2009 11:03:33 -0700
Message-ID: <87hbvxrswa.fsf@caffeine.danplanet.com>
References: <1251134884-24491-1-git-send-email-danms@us.ibm.com>
	<1251134884-24491-2-git-send-email-danms@us.ibm.com>
	<1251136090.22398.7523.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:44257 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753047AbZHXSDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 14:03:45 -0400
In-Reply-To: <1251136090.22398.7523.camel@nimitz> (Dave Hansen's message of "Mon\, 24 Aug 2009 10\:48\:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DH> Would it make more sense to do this programatically?

If it pleases the court, sure :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
