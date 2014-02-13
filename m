From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] net: phy: use network device in phy_print_status
Date: Wed, 12 Feb 2014 19:13:13 -0500 (EST)
Message-ID: <20140212.191313.1073971139703427607.davem@davemloft.net>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
	<1392168462-18888-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbaBMANO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:13:14 -0500
In-Reply-To: <1392168462-18888-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Series applied, but this patch series had several problems which I want you
absolutely to correct in future submissions.

First of all, when you submit more than one patch at a time, you must
provide a leading "PATCH 00/NN" posting which gives a top-level,
detailed, description of the overall nature of the changes you are
submitting.

It also gives me a single, specific, posting to reply to when I reply
the whole series.  Otherwise I have only two options, 1) pick an
arbitrary patch to reply to (which I am doing right now) or 2) reply
to every single patch (which is a serious waste of everyone's time).

Furthermore, some of your patches added empty lines to the end of files.
I corrected this by hand, but please avoid this in the future.

Thank you.
