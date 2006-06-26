From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 3/4] Network namespaces: IPv4 FIB/routing in namespaces
Date: Mon, 26 Jun 2006 16:56:46 +0200
Message-ID: <449FF5AE.2040201@fr.ibm.com>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:60448 "EHLO
	mtagate5.de.ibm.com") by vger.kernel.org with ESMTP id S932318AbWFZO4s
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 10:56:48 -0400
To: Andrey Savochkin <saw@swsoft.com>
In-Reply-To: <20060626135427.C28942@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Savochkin wrote:
> Structures related to IPv4 rounting (FIB and routing cache)
> are made per-namespace.

How do you handle ICMP_REDIRECT ?



