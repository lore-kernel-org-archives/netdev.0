From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 18:36:53 -0800
Message-ID: <20100105183653.2e5719e4@nehalam>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
	<20100105090717.15d532ce@nehalam>
	<99737F4847ED0A48AECC9F4A1974A4B80CFE94343B@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35393 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862Ab0AFChJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 21:37:09 -0500
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80CFE94343B@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Jan 2010 20:24:18 -0600
Amit Salecha <amit.salecha@qlogic.com> wrote:

> I bisected patches logically, for ease of understanding.
> If single patch is requirement, I can do that also.

Two or more patches are fine, but the order is important.
You can add each file separately, then add the config option
last.

-- 
