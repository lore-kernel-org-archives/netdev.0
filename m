From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: do not use -ENOENT
Date: Thu, 17 Jan 2013 16:18:51 -0500 (EST)
Message-ID: <20130117.161851.1892742893363555925.davem@davemloft.net>
References: <20130117205212.GB1591@minipsycho.orion>
	<20130117.160742.614484345035625041.davem@davemloft.net>
	<20130117211532.GC1591@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171Ab3AQVSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 16:18:54 -0500
In-Reply-To: <20130117211532.GC1591@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 17 Jan 2013 22:15:32 +0100

> Okay, fair enough. In that case, I believe that also the other 2
> occurrences of -ENOENT in team driver are ok as well. Please scratch this
> patch.

Ok.

> Thanks!

No problem.
