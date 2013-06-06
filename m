From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] vxlan: only migrate dynamic FDB entries
Date: Thu, 06 Jun 2013 16:16:25 -0700 (PDT)
Message-ID: <20130606.161625.178586077908629047.davem@davemloft.net>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab3FFXQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 19:16:26 -0400
In-Reply-To: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen please resolve Cong Wang's crashes and then take care of the "return
bool" and typo nit picks while you're at it, and I'll apply this series it
looks good otherwise.

Thanks!
