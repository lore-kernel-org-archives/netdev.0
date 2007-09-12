From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/16] net: Make /proc/net per network namespace
Date: Wed, 12 Sep 2007 05:19:32 -0700 (PDT)
Message-ID: <20070912.051932.59669038.davem@davemloft.net>
References: <m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
	<20070912.030211.102564635.davem@davemloft.net>
	<46E7D794.5090006@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:39228
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S968018AbXILMUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:20:09 -0400
In-Reply-To: <46E7D794.5090006@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 12 Sep 2007 14:12:04 +0200

> it seems the fs/proc/proc_net.c was not added to the git repository.

Fixed, thanks for catching that.
