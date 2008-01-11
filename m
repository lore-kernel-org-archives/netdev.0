From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: my NAPI patches
Date: Thu, 10 Jan 2008 19:44:21 -0600
Message-ID: <20080110194421.589d09df@osprey.hogchain.net>
References: <20080108.150848.116653308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:42131 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbYAKBoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 20:44:24 -0500
In-Reply-To: <20080108.150848.116653308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Jan 2008 15:08:48 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> 
> Can people do me a favor and do more constructive things like test
> that my patches really do fix the "device down during packet flood"
> bug 

Hi Dave,

Your patches seem to work for the atl1 NAPI implementation.  I can drop
the interface just fine while hammering the NIC with packets from iperf.

Jay
