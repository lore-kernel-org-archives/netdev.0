From: Robert Urban <urban@unix-beratung.de>
Subject: parsing the output of ethtool programmatically
Date: Thu, 25 Jun 2015 03:28:23 +0200
Message-ID: <558B5937.4080600@unix-beratung.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: bwh@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dna.y42.org ([176.9.161.194]:35610 "EHLO dna.y42.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334AbbFYBes (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 21:34:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

there doesn't seem to be any flag to request ethtool to present its output in a
script-friendly form.  Things like:
>         Link partner advertised link modes:  10baseT/Half 10baseT/Full
>                                              100baseT/Half 100baseT/Full
>                                              1000baseT/Full
are kind of pain to parse.

Something to consider?

Robert Urban
