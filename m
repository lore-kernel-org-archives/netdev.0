From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC] [patch 0/6] [Network namespace] introduction
Date: Tue, 20 Jun 2006 23:21:43 +0200
Message-ID: <449866E7.4050508@fr.ibm.com>
References: <20060609210202.215291000@localhost.localdomain> <20060618184734.GB27946@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:26193 "EHLO
	mtagate5.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751115AbWFTVVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 17:21:48 -0400
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20060618184734.GB27946@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro wrote:
> On Fri, Jun 09, 2006 at 11:02:02PM +0200, dlezcano@fr.ibm.com wrote:
> - renaming an interface in one "namespace" affects everyone.

Exact. If we ensure the interface can't be renamed if used in different 
namespace, is it really a problem ?

