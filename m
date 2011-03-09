From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 1/2] ethtool: Support no-cache copy in config
Date: Wed, 09 Mar 2011 10:09:26 -0800
Message-ID: <1299694166.2087.70.camel@tardy>
References: <alpine.DEB.2.00.1103082056010.4814@pokey.mtv.corp.google.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:32808 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302Ab1CISTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 13:19:01 -0500
In-Reply-To: <alpine.DEB.2.00.1103082056010.4814@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-08 at 21:05 -0800, Tom Herbert wrote:
> Add support for nccopy configuration as an offload option.  This allows
> enabling and disabling no-cache copies in copy-from-user on
> transmission for a device.

Does/should it depend on CKO being enabled on the device?

rick jones

