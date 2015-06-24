From: David Miller <davem@davemloft.net>
Subject: Re: merge window freeze
Date: Wed, 24 Jun 2015 05:41:34 -0700 (PDT)
Message-ID: <20150624.054134.167274466460545100.davem@davemloft.net>
References: <20150624.025328.682044271321726878.davem@davemloft.net>
	<EC3F09A3-8B3D-4ABD-B94D-1A36D13DF09A@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbFXMaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 08:30:07 -0400
In-Reply-To: <EC3F09A3-8B3D-4ABD-B94D-1A36D13DF09A@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Wed, 24 Jun 2015 13:25:47 +0300

> I noticed that both of my bridge patches are marked with “Changes Requested”, but
> there was no feedback why and also the first one:
> "bridge: multicast: add a comment to br_port_state_selection about blocking state”
> was ACKed and in the second one our discussion with Toshiaki
> was about a possible bug that’s not related to the patch. 
> Could you please tell me what I have to change in them ?
> 
> Patch links:
> [1] https://patchwork.ozlabs.org/patch/487591/
> [2] https://patchwork.ozlabs.org/patch/487608/
> 

Indeed, I misread the feedback on patch #2.

Series applied, thanks.
