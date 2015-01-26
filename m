From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH 0/2 net-next] sunvnet: fix null pointer deref and crash
 recovery
Date: Mon, 26 Jan 2015 17:44:32 -0500
Message-ID: <20150126224432.GG6437@oracle.com>
References: <54C6A976.4060502@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42887 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbbAZWog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 17:44:36 -0500
Content-Disposition: inline
In-Reply-To: <54C6A976.4060502@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/26/15 15:54), David L Stevens wrote:
> These patches fix an incorrect ordering in releasing ring data, clear pending
> tx buffers on a reset, and make the sunvnet driver more reliable when remote
> systems crash during active transmits.

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
