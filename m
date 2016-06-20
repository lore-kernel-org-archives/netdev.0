From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: rcu locking issue in mpls output code?
Date: Mon, 20 Jun 2016 12:37:41 -0700
Message-ID: <20160620123741.71401da7@xeon-e3>
References: <20160620004546.GP20238@wantstofly.org>
	<8d325ab7-bc46-dd69-288a-571d56efc545@cumulusnetworks.com>
	<20160620063055.GR20238@wantstofly.org>
	<7d7097bc-ce10-d8e1-4a90-36045c7d2041@cumulusnetworks.com>
	<CAJieiUi8WX1=Yri_b8aZpP2sEkQ6CqARcX29M94Qdf4gczFDjg@mail.gmail.com>
	<20160620163317.GS20238@wantstofly.org>
	<e84c7422-c688-faec-54ac-e0a5607d6c3d@cumulusnetworks.com>
	<20160620174408.GT20238@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32972 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021AbcFTThw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 15:37:52 -0400
Received: by mail-pf0-f172.google.com with SMTP id i123so53238228pfg.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 12:37:27 -0700 (PDT)
In-Reply-To: <20160620174408.GT20238@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> ifconfig tons 172.16.20.20 netmask 255.255.255.0

Really, still using ifconfig?
