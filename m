From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net-next 0/3] l2tp: module autoloading
Date: Thu, 24 Sep 2015 07:45:23 +0100
Message-ID: <56039C03.9010806@katalix.com>
References: <20150924043333.231895827@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:60735 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871AbbIXGwl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 02:52:41 -0400
In-Reply-To: <20150924043333.231895827@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/15 05:33, Stephen Hemminger wrote:
> With L2TP it was necessary to manually load modules
> which is a nuisance and not required with other tunneling
> protocols. This set of patches adds the aliases and module
> load hook to get rid of the necessity of modprobing.
Looks good.

Acked-By: James Chapman <jchapman@katalix.com>
