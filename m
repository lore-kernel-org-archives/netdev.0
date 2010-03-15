From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/3] jme: Adding lock to protect vlgrp
 structure.
Date: Mon, 15 Mar 2010 15:54:53 -0700 (PDT)
Message-ID: <20100315.155453.143098808.davem@davemloft.net>
References: <1268630108-10374-1-git-send-email-cooldavid@cooldavid.org>
	<1268630108-10374-2-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937023Ab0COWyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:54:32 -0400
In-Reply-To: <1268630108-10374-2-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please respin this whole patch set when you fix this
vlgrp locking the way I told you to.

Also, please don't submit a seperate series for 2.6.33 it only creates
confusion.  Just add a "CC: stable@kernel.org" right after your
signoff line and it'll get sorted out automatically once the patch
reaches Linus's tree.
