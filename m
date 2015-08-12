From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 6/6] misc/ss: fix memory leak in user_ent_hash_build()
Date: Wed, 12 Aug 2015 09:27:38 -0700
Message-ID: <20150812092738.07b13f17@urahara>
References: <1438863876-1935-1-git-send-email-phil@nwl.cc>
	<1438863876-1935-2-git-send-email-phil@nwl.cc>
	<1438863876-1935-3-git-send-email-phil@nwl.cc>
	<1438863876-1935-4-git-send-email-phil@nwl.cc>
	<1438863876-1935-5-git-send-email-phil@nwl.cc>
	<b64bd55adf5d4f96b8f4d6e414161fad@BRMWP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35322 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114AbbHLQ1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 12:27:36 -0400
Received: by pdrg1 with SMTP id g1so8967865pdr.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 09:27:35 -0700 (PDT)
In-Reply-To: <b64bd55adf5d4f96b8f4d6e414161fad@BRMWP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Aug 2015 12:24:36 +0000
Phil Sutter <phil@nwl.cc> wrote:

> Signed-off-by: Phil Sutter <phil@nwl.cc>

I applied the rest of these as is.
